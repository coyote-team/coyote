require "spec_helper"

RSpec.describe ScavengerHunt::Game do

  let(:organization) { create(:organization) }

  let(:answer_metum) { create(:metum, organization: organization, title: ScavengerHunt::Game::ANSWER_METUM_NAME) }
  let(:clue_metum) { create(:metum, organization: organization, title: ScavengerHunt::Game::CLUE_METUM_NAME) }
  let(:clue_prompt_metum) { create(:metum, organization: organization, title: ScavengerHunt::Game::CLUE_PROMPT_METUM_NAME) }
  let(:hint_metum) { create(:metum, organization: organization, title: ScavengerHunt::Game::HINT_METUM_NAME) }

  let(:resource_1) { create(:resource, organization: organization) }
  let(:resource_2) { create(:resource, organization: organization) }
  let(:resource_3) { create(:resource, organization: organization) }

  let!(:answer_1) { create(:representation, metum: answer_metum, resource: resource_1, status: "approved") }
  let!(:clue_1_1) { create(:representation, metum: clue_metum, ordinality: 0, resource: resource_1, status: "approved") }
  let!(:clue_1_2) { create(:representation, metum: clue_metum, ordinality: 10, resource: resource_1, status: "approved") }
  let!(:clue_1_2) { create(:representation, metum: clue_metum, ordinality: 10, resource: resource_1, status: "approved") }
  let!(:prompt_1) { create(:representation, metum: clue_prompt_metum, resource: resource_1, status: "approved") }

  let!(:answer_2) { create(:representation, metum: answer_metum, resource: resource_2, status: "approved") }
  let!(:prompt_2) { create(:representation, metum: clue_prompt_metum, resource: resource_2, status: "approved") }
  let!(:clue_2_1) { create(:representation, metum: clue_metum, ordinality: 3, resource: resource_2, status: "approved") }
  let!(:clue_2_2) { create(:representation, metum: clue_metum, ordinality: 2, resource: resource_2, status: "approved") }

  let!(:answer_3) { create(:representation, metum: answer_metum, resource: resource_3, status: "not_approved") }
  let!(:clue_3_1) { create(:representation, metum: clue_metum, resource: resource_3, status: "approved") }
  let!(:clue_3_2) { create(:representation, metum: clue_metum, resource: resource_3, status: "approved") }

  let(:location) { ScavengerHunt::Location.create!(organization: organization, tint: "#ff0000") }
  let(:player) { ScavengerHunt::Player.create!(ip: "127.0.0.1", user_agent: "test") }
  subject { ScavengerHunt::Game.create!(location: location, player: player) }

  fit "generates clues for the first approved clue representation with a valid answer by resource" do
    expect(subject.clues.count).to eq(2)
    expect(subject.clues.first.representation).to eq(clue_1_1)
    expect(subject.clues.last.representation).to eq(clue_2_2)
  end

  fit "uses the answer metum to generate answers" do
    expect(subject.clues.first.answer).to eq(answer_1.text)
    expect(subject.clues.last.answer).to eq(answer_2.text)
  end

  fit "uses the prompt metum to set clue prompts" do
    expect(subject.clues.first.prompt).to eq(prompt_1.text)
    expect(subject.clues.last.prompt).to eq(prompt_2.text)
  end

end
