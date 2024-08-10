require "csv"
require "erb"
require "google/apis/civicinfo_v2"

def clean_zipcode(zip)
  zip.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read("civic_info.key").strip

  begin
    civic_info.representative_info_by_address(
      address: zipcode,
      levels: "country",
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def clean_phone_number(phone_number)
  formatted_number = phone_number.gsub(/[^\d]/, "")
  return formatted_number if formatted_number.length == 10
  return formatted_number[1..10] if formatted_number.length == 11 && formatted_number[0] == "1"

  "Invalid phone number"
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

contents.each do |row|
  # "first_name" and "legislators" are called in the "erb_template"
  id = row[0]
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  # phone_number has been formatted below
  # phone_number = clean_phone_number(row[:homephone])

  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end
