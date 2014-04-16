json.array!(@inspections) do |inspection|
  json.extract! inspection, :id, :id, :premise_id, :date, :inspection_reason, :note, :result, :details, :details_short
  json.url inspection_url(inspection, format: :json)
end
