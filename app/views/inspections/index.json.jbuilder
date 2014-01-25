json.array!(@inspections) do |inspection|
  json.extract! inspection, :id, :id, :premise_id, :date, :inspection_reason, :note, :passed
  json.url inspection_url(inspection, format: :json)
end
