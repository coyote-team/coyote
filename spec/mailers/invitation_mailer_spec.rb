# frozen_string_literal: true

RSpec.describe InvitationMailer do
  let(:organization) { build_stubbed(:organization) }
  let(:invitation) { build_stubbed(:invitation, organization: organization) }

  describe "new_user" do
    let(:mail) do
      described_class.new_user(invitation)
    end

    it "renders the headers" do
      expect(mail.subject).to match(organization.name)
      expect(mail.to).to eq([invitation.recipient_email])
    end

    it "renders the body" do
      aggregate_failures do
        mail.parts.each do |part|
          expect(part.encoded).to match(/you have been invited/i), "could not find a match in the #{part.content_type} email part"
        end
      end
    end
  end

  describe "existing_user" do
    let(:mail) do
      described_class.existing_user(invitation)
    end

    it "renders the headers" do
      expect(mail.subject).to match(organization.name)
      expect(mail.to).to eq([invitation.recipient_email])
    end

    it "renders the body" do
      aggregate_failures do
        mail.parts.each do |part|
          expect(part.encoded).to match(/you have been added/i), "could not find a match in the #{part.content_type} email part"
        end
      end
    end
  end
end
