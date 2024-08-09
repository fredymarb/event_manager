require 'csv'
puts 'EventManager initialized.'

def clean_zipcode(zip)
  zip.to_s.rjust(5, "0")[0..4]
end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  puts "#{first_name}: #{zipcode}"
end
