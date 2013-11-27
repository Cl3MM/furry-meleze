json.array!(@ebsdds) do |ebsdd|
  json.extract! ebsdd, :producteur
  json.url ebsdd_url(ebsdd, format: :json)
end
