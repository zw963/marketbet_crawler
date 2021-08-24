class Types::Objects::StockType < GraphQL::Schema::Object
  description('Stock')

  field(:name, String, null: false, description: 'Stock name')
  field(:exchange_name, String, null: false, description: 'Exchange name')

  def exchange_name
    object.exchange.name
  end
end
