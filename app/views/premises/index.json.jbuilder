json.array!(@premises) do |premise|
  json.extract! premise, :id, :id, :name, :premise_type, :address
  json.url premise_url(premise, format: :json)
end
