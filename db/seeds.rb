require "factory_girl_rails"

begin
  FactoryGirl.find_definitions 
rescue FactoryGirl::DuplicateDefinitionError 
  # necessary to be able to use the rake db:seed task where we want, argh
  Rails.logger.debug "Factory Girl definitions previously loaded"
end

organization = FactoryGirl.create(:organization,title: "Acme Museum")

organization.contexts.create!([
  { title: "collection" },
  { title: "website" },
  { title: "exhibitions" },
  { title: "events" },
])

short_metum = FactoryGirl.create(:metum,:short)
long_metum  = FactoryGirl.create(:metum,:long)

Status.create!([
  { title: "Ready to review" },
  { title: "Approved" },
  { title: "Not approved" }
])

image = FactoryGirl.create(:image,{
  organization: organization,
  path: "https://coyote.pics/wp-content/uploads/2016/02/Screen-Shot-2016-02-29-at-10.05.14-AM-1024x683.png",
  title: "T.Y.F.F.S.H., 2011"
})

alt_text = "A red, white, and blue fabric canopy presses against walls of room; portable fans blow air into the room through a doorway."

long_text = <<-TEXT
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

FactoryGirl.create(:description,image: image,metum: short_metum,text: alt_text)
FactoryGirl.create(:description,image: image,metum: long_metum,text: long_text)

undescribed_image = FactoryGirl.create(:image,{
  organization: organization,
  path: 'http://example.com/image123.png',
  title: 'Mona Lisa'
})

Coyote::Membership.each_role do |_,role_id|
  email = "#{role_id}@example.com"

  user = FactoryGirl.create(:user,organization: organization,role: role_id,email: email,password: "password")
  Assignment.create(image: undescribed_image,user: user)

  puts "Created #{role_id} user '#{email}' with password 'password'"
end
