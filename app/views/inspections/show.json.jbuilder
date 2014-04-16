json.extract! @inspection, :id, :id, :premise_id, :date, :inspection_reason, :note, :result, :details, :details_short
json.infractions do
	json.array!(@inspection.infractions) do |infraction|
	  json.extract! infraction, :id, :id, :infraction_type, :text
	end
end