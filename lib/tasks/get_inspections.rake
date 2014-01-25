require 'benchmark'
require "selenium-webdriver"

task :get_inspections => :environment do

  puts Benchmark.measure {
    # Just keep looping until the importer says it's done. (Take 300-350 seconds on a good internet connection, with few new inspections.)
    done = false
    ii = InspectionImporter.new
    while !done
      done = ii.import
    end
    ii.driver.quit
  }

end
