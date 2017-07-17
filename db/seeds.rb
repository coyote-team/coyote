require "factory_girl_rails"

Group.create!([
  {id: 1, title: "collection"},
  {id: 2, title: "website"},
  {id: 3, title: "exhibitions"},
  {id: 4, title: "events "},
])
Metum.create!([
  {id: 1, title: "Alt", instructions: "A long description is a lengthier text than a traditional alt-text that attempts to provide a . comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs."},
  #{id: 2, title: "Caption", instructions: "This is the caption text to be displayed visibly. This text will also be read to a blind user so it is best not to repeat info from this item in the alt text."},
  {id: 3, title: "Long", instructions: "A long description is a lengthier text than a traditional alt-text that attempts to provide a . comprehensive representation of an image. Long descriptions can range from one sentence to several paragraphs."}
])
Status.create!([
  {id: 1, title: "Ready to review"},
  {id: 2, title: "Approved"},
  {id: 3, title: "Not approved"}
])

FactoryGirl.create(:user,:admin,email: ENV["SUPPORT_EMAIL"],first_name: "Support", last_name: "User")
FactoryGirl.create(:website)
