task :report, [:date] => [:environment] do |t, args|
	if args[:date]
		d = Date.parse( args[:date] )
	else
		d = Date.today
	end
	puts d

	inspections = Inspection.where("created_at > ?", d)
	puts "Inspections: #{inspections.length}"

	yellows = Inspection.where("created_at > ? AND result = 'Conditional Pass'", d).includes( :premise )
	puts "Yellows: #{yellows.length}"
	yellows.each do |i|
		puts "- #{i.premise.id}, #{i.premise.name}: #{i.details_short}"
	end

	reds = Inspection.where("created_at > ? AND result = 'Fail'", d).includes( :premise )
	puts "Reds: #{reds.length}"
	reds.each do |i|
		puts "- #{i.premise.id}, #{i.premise.name}: #{i.details_short}"
	end
end