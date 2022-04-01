class App
  hash_routes('graphql') do
    is true do |r|
      load = JSON.load(r.body)

      ApplicationSchema.execute(
        query:          load['query'],
        variables:      load['variables'],
        context:        load['context'],
        operation_name: load['operationName']
      ).to_h
    end
  end
end
