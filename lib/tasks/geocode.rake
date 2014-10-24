# NOTE -> Location 1196 is problematic. It's just "Hamilton, Ontario"

require 'net/http'
require 'uri'
require 'open-uri'
require 'json'

task :geocode => :environment do |t, args|

    regex = []
    regex << /(\d+) - (.+) , (.+)/
    regex << /(\d+) ?, (.+) , (.+)/
    regex << /(\d+) (.+) , (.+)/

    premises = Premise.where(location_id: nil)
    premises.each do |p|
        match = nil
        regex.each do |r|
            match = r.match( p.address )
            break unless match.nil?
        end

        if match
            city = match[3]
            city = 'Hamilton' if city.start_with? 'Hamilton'

            street = match[2]
            # Addresses on King or Main Streets in Westdale have 'WE' in them (eg, 123 WE King Street, Hamilton). Account for this.
            if street.start_with? 'WE '
                city = 'Westdale'
                street = street[3, street.length-3]
            end

            result = get_result( match[1], street, city )
            if result.nil?
                puts 'No results.'
                next
            end

            # puts "#{result['formatted_address']} -> #{result['geometry']['location']['lat']},#{result['geometry']['location']['lng']}"

            l = get_location result
            puts "LID: #{l.id}"
            p.location_id = l.id
            p.save!
            sleep 2 # Throw a sleep in so we don't get rate-limited by Google.
        else
            puts "Address for #{p.name} is invalid ( #{p.address} )"
        end
    end
end

def get_result( number, street, city )
    address = "#{number} #{street}, #{city}, ON"

    puts address

    uri = URI.parse("http://maps.googleapis.com/maps/api/geocode/json?address=#{ URI::encode( address ) }")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response_obj = JSON.parse( response.body )

    if response_obj['results'].length == 0
        if city != 'Hamilton'
            return get_result( number, street, 'Hamilton' )
        else
            return nil
        end
    end

    result = response_obj['results'][0]
    return result
end

def get_location( result )
    lat = result['geometry']['location']['lat'].to_f.round(4)
    lng = result['geometry']['location']['lng'].to_f.round(4)

    puts "#{result['formatted_address']} -> #{lat},#{lng}"

    l = Location.where( lat: lat, lng: lng ).first
    if l.nil?
        l = Location.new( lat: lat, lng: lng )
        l.save!
    end
    return l
end