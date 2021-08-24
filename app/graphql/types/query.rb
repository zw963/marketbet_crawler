class Types::Query < GraphQL::Schema::Object
  description('The query root of this schema')

  field(:stock, Types::Objects::StockType, null: true) do
    description('Find a stock')
  end

  def stock
    Stock.first
  end
end
