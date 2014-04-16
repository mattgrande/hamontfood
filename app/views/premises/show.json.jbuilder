json.extract! @premise, :id, :id, :name, :premise_type, :address, :created_at
json.inspections do
	json.array!(@inspections) do |inspection|
	  json.extract! inspection, :id, :id, :premise_id, :date, :inspection_reason, :note, :result, :details, :details_short
	end
end