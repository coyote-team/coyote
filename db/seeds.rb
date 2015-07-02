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
  {id: 1, title: "Ready to review", description: ""},
  {id: 2, title: "Approved", description: ""},
  {id: 3, title: "Not approved", description: ""}
])
Website.create!([
  {id: 1, title: "Museum Of Contemporary Art Chicago", url: "http://www2.mcachicago.org/"}
])
Image.create!([
  {id: 1, url: "/wp-content/uploads/2015/05/smlxl_carousel_image_2x-975x549.jpg", website_id: 1, group_id: 1},
  {id: 2, url: "/wp-content/uploads/2015/05/Danny_Volk-185x203.jpg", website_id: 1, group_id: 1},
  {id: 3, url: "/wp-content/uploads/2013/09/sunglasses_grouped_edit.jpg", website_id: 1, group_id: 1},
])
User.create!([
  {id: 1, email: "coyote_dev@seeread.info", password: "asdfasdf"},
  {id: 2, email: "coyote_admin@seeread.info", admin: true , password: "asdfasdf"},
])
Assignment.create!([
  {id: 1, user_id: 1, image_id: 1},
  {id: 2, user_id: 1, image_id: 2},
  {id: 3, user_id: 2, image_id: 2},
])
Description.create!([
  #image 1 : completed
  {id: 1, locale: "en", text: "This is a test alt for image 1.", status_id: 2, image_id: 1, metum_id: 1, user_id: 1},
  {id: 2, locale: "en", text: "This is a test caption for image 1.", status_id: 2, image_id: 1, metum_id: 2, user_id: 1},
  {id: 3, locale: "en", text: "This is a test long description for image 1.", status_id: 2, image_id: 1, metum_id: 3, user_id: 2},
  #image 2 : 1 description ready to review
  {id: 4, locale: "en", text: "This is a test alt for image 2.", status_id: 2, image_id: 2, metum_id: 1, user_id: 1},
  {id: 5, locale: "en", text: "This is a test caption for image 2.", status_id: 2, image_id: 2, metum_id: 2, user_id: 1},
  {id: 6, locale: "en", text: "This is a test long description for image 2.", status_id: 1, image_id: 2, metum_id: 3, user_id: 1}
])
