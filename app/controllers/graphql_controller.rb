class GraphqlController < ApplicationController
  PERSISTED_QUERIES = JSON.parse(File.read(Rails.root.join('persisted-query-ids', 'server.json')))

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  protect_from_forgery with: :null_session

  def execute
    if params[:query] && (Rails.env.production? || ENV['GRAPHQL_PERSISTED_QUERY_REQUIRED'].present?)
      return render json: { errors: [{ message: 'Query is not allowed. Use query hash instead.' }], data: {} }, status: 400
    end

    query_hash = context[:extensions]&.dig('persistedQuery', 'sha256Hash')
    query = PERSISTED_QUERIES[query_hash] || params[:query]

    if query.present? && request.method == 'GET' && query.start_with?('mutation')
      return render json: { errors: [{ message: 'Mutation must be requested with POST.' }], data: {} }, status: 400
    end

    variables = prepare_variables(params[:variables])
    operation_name = params[:operationName]
    result = TrustedQueriesSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def context
    {
      extensions: prepare_variables(params[:extensions]),
    }
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end
