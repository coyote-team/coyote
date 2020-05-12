# frozen_string_literal: true

require "factory_bot_rails"

begin
  FactoryBot.find_definitions
rescue FactoryBot::DuplicateDefinitionError
  # necessary to be able to use the rake db:seed task where we want, argh
  Rails.logger.debug "Factory Girl definitions previously loaded"
end

organization = FactoryBot.create(:organization, title: "Acme Museum")

resource_groups = organization.resource_groups.create!([
  {title: "collection"},
  {title: "website"},
  {title: "exhibitions"},
  {title: "events"},
])

short_metum = FactoryBot.create(:metum, :short, organization: organization)
long_metum = FactoryBot.create(:metum, :long, organization: organization)

FactoryBot.factories[:license].defined_traits.to_a.map do |trait|
  FactoryBot.create(:license, trait.name)
end

resource = FactoryBot.create(:resource, {
  title:           "T.Y.F.F.S.H., 2011",
  organization:    organization,
  resource_groups: [resource_groups.first],
  source_uri:      "https://coyote.pics/wp-content/uploads/2016/02/Screen-Shot-2016-02-29-at-10.05.14-AM-1024x683.png",
})

alt_text = "A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway."

long_text = <<~TEXT
  This is an installation that viewers are invited to walk inside of. From this viewpoint you are looking through a doorway at a slight distance,
  as if standing inside of a large cave and looking out of its narrow entrance at the world outside. The walls of this cave are alternating stripes of
  red, white, and blue material that seems to be made of some kind of thin fabric. These colored stripes spiral around toward the entrance, as if
  being sucked out of the opening. The inside of the cave is more shadowed and the area outside is brightly lit. Gradually you notice that there
  are in fact two openings lined up in front of each other, straight ahead of you: the first one is a tall rectangle—the red, white and blue fabric
  is wrapped through the edges of a standard doorway; beyond that it continues to spiral around toward another circular opening.  The center of
  this circle is much brighter, as if one had finally escape from the cave. At the center of that circular opening you see two large white fans
  facing your direction, blowing air into the cave-like opening. Beyond the fans you see a brown, square form, which is the bottom of a
  huge wicker basket. This basket, lying on its side, helps to reveal the truth about what you are seeing: You are standing inside of a huge
  hot air balloon, which is lying on its side. Blown by the fans, the fabric billows out to press out against the existing walls of a large room,
  the malleable shape of the balloon conforming to the rectangular surfaces of an existing building–the gallery that contains it.
TEXT

FactoryBot.create(:representation, resource: resource, metum: short_metum, text: alt_text)
FactoryBot.create(:representation, resource: resource, metum: long_metum, text: long_text)

undescribed_resource = FactoryBot.create(:resource, {
  title:        "Installation view, _The Making of A Fugitive_, MCA Chicago, Jul 16–Dec 4,2016",
  organization: organization,
  source_uri:   "https://mcachicago.org/api/v1/attachment_images/thumbs/57c06fc6101f31476d000044.jpg",
})

# undescribed, unassigned resource
FactoryBot.create(:resource, {
  title:        "Unknown",
  organization: organization,
  source_uri:   "https://mcachicago.org/api/v1/attachment_images/thumbs/55bb7af13164660b2f000a36.jpg",
})

# TODO: Generate more resources

Coyote::Membership.each_role do |_, role_id|
  email = "#{role_id}@example.com"

  user = FactoryBot.create(:user, organization: organization, role: role_id, email: email, password: "password")
  Assignment.create(resource: undescribed_resource, user: user)

  puts "Created #{role_id} user '#{email}' with password 'password'"
end

email = "staff@example.com"
FactoryBot.create(:user, :staff, email: email, password: "password")
puts "Created staff user '#{email}' with password 'password'"
