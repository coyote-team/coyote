Description.create!([
  {locale: "en", text: "", status_id: 64, image_id: 64, metum_id: 47}
])
Group.create!([
  {title: "collection"},
  {title: "website"},
  {title: "exhibit"}
])
Image.create!([
  {url: "/wp-content/uploads/2015/05/smlxl_carousel_image_2x-975x549.jpg", website_id: 43}
])
Metum.create!([
  {title: "alt", instructions: ""},
  {title: "caption", instructions: ""},
  {title: "description", instructions: ""}
])
Status.create!([
  {title: "Unassigned", description: ""},
  {title: "Assigned", description: ""},
  {title: "Ready for review", description: ""},
  {title: "Published", description: ""}
])
Website.create!([
  {title: "Museum Of Contemporary Art Chicago", url: "http://www2.mcachicago.org/"}
])
