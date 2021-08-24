class ApplicationSchema < GraphQL::Schema
  query(Types::Query)
end
