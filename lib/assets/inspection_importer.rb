
class InspectionImporter

  attr :driver
  attr :most_recent_inspections
  attr :premise_count
  attr :inspection_count

  # Here's a quick rundown of how this whole thing works.
  # 1. Get all the different types of premises (eg, Deli, Grocery Store, Food Truck, etc)
  # 2. Loop through each type of premise
  #    2.1. Loop through each of the premises on the results page
  #         2.1.1. If the saved, most-recent inspection is the same as the current most-recent inspection, move on to the next location
  #         2.1.2. If there are new inspections, import them
  #         2.1.3. Since there are no permalinks, we have to go all the way back out to the search page, and start again (Step 2)
  #    2.2. If we reach the end of the page, click the 'Next Page' link.
  #    2.3. Otherwise, we've reached the end, return true.
  # 3. If true was returned in 2.3, remove this premise type from the list (so we don't have to try to load it again). Move on to the next premise type.
  def initialize
    @driver = Selenium::WebDriver.for :chrome
    @most_recent_inspections = {}
    @premise_count = 0
    @inspection_count = 0

    # Get all the existing premises & their inspections
    premises = ActiveRecord::Base.connection.execute("SELECT p.id AS id, i.id AS i_id FROM premises p INNER JOIN inspections i ON p.id = i.premise_id")
    premises.each do |p|
      unless @most_recent_inspections.has_key? p['id']
        @most_recent_inspections[ p['id'] ] = {:complete => true, :inspections => []}
      end
      @most_recent_inspections[ p['id'] ][ :inspections ] << p['i_id']
    end

    puts "#{ @most_recent_inspections.length } premises, #{ premises.length } inspections, found."
  end

  def import
    
    # Navigate to the food safety site
    @driver.navigate.to "http://www.foodsafetyzone.ca/zone3.asp"

    # Get a list of all the premise types
    select = @driver.find_element(:name, 'SearchType')
    premise_types = []
    all_options = select.find_elements(:tag_name, "option")
    all_options.each do |option|

      value = option.attribute("value")
      next if value == "All"
      premise_types << value

    end

    # Import all the data for each premise type
    all_loaded = true
    while premise_types.length > 0
      premise_types.each do |premise_type|
        this_loaded = import_premise_type( premise_type )
        all_loaded = this_loaded && all_loaded

        # If this type has been fully loaded, remove it from the list so we don't try to load it again.
        if this_loaded
          puts "Removing #{premise_type}; all loaded. #{ premise_types.length } types remaining."
          premise_types.delete( premise_type )
        end
      end
    end

    puts "All Loaded? #{all_loaded}"
    return all_loaded
  end

private
  def import_premise_type( type )

    # Navigate to the food safety site
    @driver.navigate.to "http://www.foodsafetyzone.ca/zone3.asp"

    select = @driver.find_element(:name, 'SearchType')
    all_options = select.find_elements(:tag_name, "option")
    all_options.each do |option|

      # There's a 'Complete this survey' popup. Click 'No Thanks.'
      click_no_thanks

      # Select the current premise type from the dropdown list...
      next unless option.attribute("value") == type
      option.click

      # ... and click the "Search" button
      links = @driver.find_elements(:tag_name, "a")
      links.each do |link|
        if link.attribute("href") == 'javascript:validateSearch();'
          link.click
          break
        end
      end
      break
    end

    # Keep looping until we find something worth importing, or until we hit the end.
    done_loading = false
    while true
      status =  import_list type
      
      if status == :goto_next_page

        # We've hit the end of this page, let's try and go to the next page.
        next_page_found = false
        driver.find_elements(:tag_name, "a").each do |a|
          if a.attribute("title") == "Next"
            a.click
            next_page_found = true
            break
          end
        end

        unless next_page_found
          # We couldn't find a 'Next' link to click
          # We're done loading this type.
          done_loading = true
          break
        end
      elsif status == :reload_this_page
        # We've found something worth loading, and are not yet done.
        done_loading = false
        break
      elsif status == :goto_next_type
        # We're done loading this type.
        done_loading = true
        break
      end
    end

    return done_loading
  end

  def click_no_thanks
    begin
      no_thanks = @driver.find_elements(:class_name, "fs-cancel")
      if no_thanks.length > 0
        no_thanks[0].click
      end
    rescue Exception => e
      # Don't do anything.  
    end
  end

  def import_list( premise_type )

    # We're going to the next page. Let's wait for the table to show up before continuing.
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)

    status = :goto_next_page
    begin
      table = wait.until { @driver.find_elements(:tag_name, "table")[1] }

      # Okay, the page is loaded.
      status = :goto_next_page
      table.find_elements(:tag_name, "tr").each do |row|
        first_td = row.find_elements(:tag_name, "td")[0]
        next if first_td.nil?   # Probably a header, with only TH tags.
        link = first_td.find_elements(:tag_name, "a")[0]
        next if link.nil?     # Probably a footer

        # Fucking javascript in the href. This is some clownshoes bullshit.
        # The href will look like this: 
        # javascript:validateSelect('{830ADB89-5F4A-4F67-98BE-8B8A18F17B89}', '9/21/2012', '{BB49B467-7391-43F5-A2D4-988D71DE6D57}');
        # That first guid is the Premise ID, and the second guid is that premise's Most Recent Inspection ID.
        js = link.attribute("href")
        matches = /\{(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})\}.+\{(\w{8}-\w{4}-\w{4}-\w{4}-\w{12})\}/.match( js )
        premise_id = matches[1]
        inspection_id = matches[2]
        premise = @most_recent_inspections[premise_id]

        if premise != nil and premise[:complete] and premise[:inspections].include? inspection_id
          # This premise has already been fully loaded (ie, it's marked as complete, and the most-recent inspection ID matches the current inpsection ID).
        else
          # This premise either does not exist, or is not up to date. Let's import it.
          link.click

          all_inspections_loaded = false
          until all_inspections_loaded
            all_inspections_loaded = get_inspections premise_id, inspection_id, premise_type
          end
          status = :reload_this_page
          break
        end
      end
    rescue Selenium::WebDriver::Error::TimeOutError => e
      status = :goto_next_type
    end

    return status
  end

  def get_inspections( premise_id, inspection_id, premise_type )
    
    # We're looking at an "Inspection" page. Let's load the data.
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)

    previously_loaded = true
    premise = @most_recent_inspections[premise_id]
    if premise != nil and premise[:inspections].include? inspection_id

      # Loop through each inspection until we find one that has not been loaded.
      table = wait.until { @driver.find_element(:tag_name, "table") }
      table.find_elements(:tag_name, "tr").each do |tr|
        td = tr.find_elements(:tag_name, "td")[0]
        next if td.nil?    # Header, TH's only.
        a = td.find_elements(:tag_name, "a")[0]
        next if a.nil?
        
        # More fucking js in an href.
        js = a.attribute("href")
        matches = /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/.match( js )
        inspection_id = matches[0]

        if premise[:inspections].include? inspection_id
          previously_loaded = true
        else
          # This sucker hasn't been loaded yet. Click the link, and let's load it.
          previously_loaded = false
          a.click
          break
        end
      end
    else
      previously_loaded = false
    end

    # We've gone through all the inspections for this premise. They've all been loaded.
    # We're done here.
    if previously_loaded
      premise[:complete] = true
      return true
    end

    # Wait until the page loads.
    h1 = wait.until { @driver.find_element(:tag_name, "h1") }
    
    # If necessary, create a new Premise
    unless @most_recent_inspections.has_key? premise_id

      @most_recent_inspections[ premise_id ] = {
        :complete => false,
        :inspections => []
      }
      premise = @most_recent_inspections[ premise_id ]

      name = h1.attribute("innerText")
      puts "CREATING NEW PREMISE: #{name} with id #{premise_id}"
      h5 = @driver.find_element(:tag_name, "h5")
      address = h5.attribute("innerText")

      p = Premise.new(
        :id => premise_id,
        :name => name,
        :address => address,
        :premise_type => premise_type
      )
      p.save!

      @premise_count += 1
    end

    # Load the inspection
    inspection = build_inspection
    inspection.premise_id = premise_id
    inspection.id = inspection_id
    inspection.save!

    @most_recent_inspections[premise_id][:inspections] << inspection_id
    @inspection_count += 1
    puts "#{@premise_count} premises; #{@inspection_count} inspections."

    return false
  end

  # Inspection data has several H4s, each followed by a UL
  # 1. Inspection Date
  # 2. Inspection Type
  # 3. Critical Infractions, or Minor Infractions, or text saying there were no infractions.
  # 4. Minor Infractions (if 3 was Critical Infractions), or Actions Taken, or nothing.
  # 5. Actions Taken, or nothing.
  def build_inspection
    
    inspection = Inspection.new
    h4s = @driver.find_elements(:tag_name, "h4")
    h4s.each_with_index do |h4, i|
      h4 = h4.attribute("innerText")
      case h4
      when "Inspection date:"
        inspection.date = @driver.find_elements(:tag_name, "ul")[i].find_element(:tag_name, "li").attribute("innerText")
      when "Inspection type:"
        inspection.inspection_reason = @driver.find_elements(:tag_name, "ul")[i].find_element(:tag_name, "li").attribute("innerText")
      when "Critical Infractions"
        add_infractions i, inspection, 'CRITICAL'
      when "Minor Infractions"
        add_infractions i, inspection, 'MINOR'
      when "Actions taken:"
        add_infractions i, inspection, 'ACTION'
      else
        inspection.note = h4
      end
    end

    set_result_from_image inspection    

    inspection.set_details

    return inspection

  end

  def add_infractions(i, inspection, infraction_type)
    lis = @driver.find_elements(:tag_name, "ul")[i].find_elements(:tag_name, "li")
    lis.each do |li|
      infraction = Infraction.new
      infraction.infraction_type = infraction_type
      infraction.text = li.attribute('innerText')
      inspection.infractions << infraction
    end
  end

  def set_result_from_image( inspection )
    imgs = @driver.find_elements(:tag_name, "img")
    imgs.each do |img|
      img_src = img.attribute("src")
      # puts "Src: #{img_src}"
      if img_src =~ /_large.jpg$/

        # This is the image of the "report."
        # It will be one of the following names:
        # none_large.jpg, green_large.jpg, yellow_large.jpg, red_large.jpg.
        if img_src =~ /green_large.jpg$/
          result = 'Passed'
        elsif img_src =~ /yellow_large.jpg$/
          result = 'Conditional Pass'
        elsif img_src =~ /red_large.jpg$/
          result = 'Fail'
        end
        inspection.result = result

        break
      end
    end
  end

end