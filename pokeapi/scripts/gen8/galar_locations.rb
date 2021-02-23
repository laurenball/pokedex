# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'csv'

# region ID for Galar, as listed in 'pokedex/data/csv/regions.csv'
GALAR_ID = '8'

# open location index in Bulbapedia
doc = Nokogiri::HTML(open('https://bulbapedia.bulbagarden.net/wiki/Category:Sword_and_Shield_locations'))

locations = doc.css('div.mw-category-group').map do |category|
  category.css('a').map do |location|
    # urls have a prepended '/'
    full_link = "https://bulbapedia.bulbagarden.net#{location.attribute('href').value}"
    { title: location.attribute('title').value, link: full_link }
  end
end.flatten

# remove overarching region location page
locations.delete_if { |location| location[:title] == 'Galar' }
CSV.open('/home/lauren/dev/pokedex/pokedex/data/csv/locations.csv', 'a+') do |location_csv|
  # read existing data into memory and grab the last ID from the final row
  existing_rows = location_csv.read
  highest_location_id = existing_rows.last.first.to_i
  first_location_id = highest_location_id + 1

  locations.each_with_index do |location, index|
    # replace spaces with a hyphen and remove all non-alphanumeric characters to match existing convention
    identifier_location_name = location[:title].downcase.gsub(/[^a-z0-9\s]/, '').gsub(' ', '-')

    location_csv << [
      "#{first_location_id + index}",
      GALAR_ID,
      identifier_location_name,
    ]
  end
end
