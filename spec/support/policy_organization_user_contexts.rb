RSpec.shared_context "guest organization user" do
  let(:org_user) do 
    double(:guest_org_user,{
      id: 100,
      guest?:  true,
      viewer?: false,
      author?: false,
      editor?: false,
      admin?:  false,
      owner?:  false,
      staff?:  false
    })
  end
end

RSpec.shared_context "viewer organization user" do
  let(:org_user) do 
    double(:viewer_org_user,{
      id: 200,
      guest?:  true,
      viewer?: true,
      author?: false,
      editor?: false,
      admin?:  false,
      owner?:  false,
      staff?:  false
    })
  end
end

RSpec.shared_context "author organization user" do
  let(:org_user) do 
    double(:author_org_user,{
      id: 300,
      guest?:  true,
      viewer?: true,
      author?: true,
      editor?: false,
      admin?:  false,
      owner?:  false,
      staff?:  false
    })
  end
end

RSpec.shared_context "editor organization user" do
  let(:org_user) do 
    double(:editor_org_user,{
      id: 400,
      guest?:  true,
      viewer?: true,
      author?: true,
      editor?: true,
      admin?:  false,
      owner?:  false,
      staff?:  false
    })
  end
end

RSpec.shared_context "admin organization user" do
  let(:org_user) do 
    double(:admin_org_user,{
      id: 500,
      guest?:  true,
      viewer?: true,
      author?: true,
      editor?: true,
      admin?:  true,
      owner?:  false,
      staff?:  false
    })
  end
end

RSpec.shared_context "owner organization user" do
  let(:org_user) do 
    double(:owner_org_user,{
      id: 500,
      guest?:  true,
      viewer?: true,
      author?: true,
      editor?: true,
      admin?:  true,
      owner?:  true,
      staff?:  false
    })
  end
end

RSpec.shared_context "staff organization user" do
  let(:org_user) do 
    double(:staff_org_user,{
      id: 500,
      guest?:  true,
      viewer?: true,
      author?: true,
      editor?: true,
      admin?:  true,
      owner?:  true,
      staff?:  true
    })
  end
end
