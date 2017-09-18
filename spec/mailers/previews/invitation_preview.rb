# Preview all emails at http://localhost:3000/rails/mailers/invitation
class InvitationPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitation/new_user
  def new_user
    InvitationMailer.new_user
  end

  # Preview this email at http://localhost:3000/rails/mailers/invitation/existing_user
  def existing_user
    InvitationMailer.existing_user
  end
end
