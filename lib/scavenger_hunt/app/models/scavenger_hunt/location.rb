class ScavengerHunt::Location < ScavengerHunt::ApplicationRecord
  before_save :set_position
  belongs_to :organization, class_name: "::Organization"

  delegate :representations, :title, to: :organization

  def representations_by_metum(metum_name)
    representations.joins(:metum).where(meta: { title: metum_name })
  end

end
