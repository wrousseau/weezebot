require 'rubygems'
require 'mechanize'

$FIRST_NAME = ''
$LAST_NAME = ''
$PHONE = ''
$EMAIL = ''

def start_url(eventId)
  return "https://www.weezevent.com/widget_billeterie.php?id_evenement=#{eventId}"
end

$url = start_url(ARGV[0])
$agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

def get_ticket()
  # Get the start page
  start_page = $agent.get($url)
  # Bail if there are no reservations
  if start_page.forms.count != 1
    puts "Reservation unavailable"
    return false
  end

  # Fill in the details for the reservation
  start_form = start_page.forms.first
  start_form.field_with(:id => /quantite_[0-9]/).value = 1

  # Submit the details and get back the contact form
  contact_info_page = start_form.submit
  # Check for the existence and get the contact form
  contact_form = contact_info_page.forms.first

  # Fill in the contact details
  contact_form.field_with(:id => /champs_3/).value = $FIRST_NAME
  contact_form.field_with(:id => /champs_2/).value = $LAST_NAME
  contact_form.field_with(:id => /champs_5/).value = $EMAIL
  contact_form.field_with(:id => /champs_36/).value = $EMAIL
  contact_form.field_with(:id => /champs_7/).value = $PHONE
  contact_form.checkbox_with(:id => /accepte_cgv/).check
  # Submit the contact details and get confirmation page
  confirmation_page = contact_form.submit

  # Confirm the reservation
  puts "Got reservation"
  return true
end

# Running the script until we manage to get a ticket
while true
  result = get_ticket()
  break if result
end
