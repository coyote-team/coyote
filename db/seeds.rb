Group.create!([
  {id: 1, title: "collection"},
  {id: 2, title: "website"},
  {id: 3, title: "exhibit"}
])
Metum.create!([
  {id: 1, title: "Alt", instructions: "Alt, or alternative, text is the text that will be read to a blind user by their screen reader. If the image is a UI element, one to two words is preferred e.g. home, Twitter, Contact Us, etc. If the image is not a UI element, then the alt text should describe the image’s main purpose or theme. It’s best to keep the alt text less than 20 to 30 words. Long description exists for longer form description. If this image has a caption, then try not to repeat caption text in this alt text."},
  {id: 2, title: "Caption", instructions: "This is the caption text to be displayed visibly. This text will also be read to a blind user so it is best not to repeat info from this item in the alt text."},
  {id: 3, title: "Long Description", instructions: "A long description is a lengthier description of an image compared to the alternative text. It is designed with description, instead of function, in mind. see description guidelines for specific guidance for aesthetics."}
])
Status.create!([
  {id: 1, title: "Unassigned", description: ""},
  {id: 2, title: "Assigned", description: ""},
  {id: 3, title: "Ready for review", description: ""},
  {id: 4, title: "Published", description: ""}
])
Website.create!([
  {id: 1, title: "Museum Of Contemporary Art Chicago", url: "http://www2.mcachicago.org/"}
])
Image.create!([
  {id: 1, url: "/wp-content/uploads/2015/05/smlxl_carousel_image_2x-975x549.jpg", website_id: 1, group_id: 1}
])
Description.create!([
  {id: 1, locale: "en", text: "", status_id: 1, image_id: 1, metum_id: 1}
])
