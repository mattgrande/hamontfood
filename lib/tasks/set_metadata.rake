# Is the 'result' of an inspection really metadata? I'm not sure...
# Anyway, this method sets things like the 'result' of an inspection (eg, Pass / Conditional Pass / Fail),
# and the details string (eg, '2 Critical Infractions, 3 Minor Infractions')
task :set_metadata => :environment do

  types = Set.new
  puts "Getting..."
  inspections = Inspection
    .includes(:infractions)
    .where("(result = '' OR result IS NULL)")

  puts "Setting metadata for #{inspections.length} inspections."
  if inspections.length > 0
    inspections.each do |inspection|
      result = 'Passed'

      inspection.infractions.where( :infraction_type => 'ACTION' ).each do |at|
        if at.text.include? 'Closure Order Served' or at.text.include? 'Red Card Issued'
          result = 'Fail'
        elsif at.text.include? 'Green Sign Removed' or at.text.include? 'Yellow Card Issued'
          result = 'Conditional Pass'
        end
      end

      inspection.result = result
      inspection.set_details
      inspection.save

      puts "#{result} - #{inspection.id}" if result != 'Passed'

    end
  end
  
end
