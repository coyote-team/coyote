class UpdateMcaurl < ActiveRecord::Migration
  def change
    w = Website.where(title: "MCA Chicago").first
    if w
      w.url = "https://mcachicago.org"
      w.save
    end
  end
end
