import { gql } from "graphql";

const Query1 = gql(/* GraphQL */ `
  query Query1 {
    __typename
  }
`);

const HelloQuery = gql(/* GraphQL */ `
  query HelloQuery {
    testField
  }
`);

const TestMutation = gql(/* GraphQL */ `
  mutation TestMutation {
    testField
  }
`);
