require "spec_helper"

RSpec.describe ScavengerHunt::Game do
  # Set up a Scavenger Hunt game
  let(:organization) { create(:organization) }
  let(:location) { ScavengerHunt::Location.create!(organization: organization, tint: "#ff0000") }
  let(:player) { ScavengerHunt::Player.create!(ip: "127.0.0.1", user_agent: "test") }

  # ...include the meta used to identify content in Coyote that powers the game
  let(:answer_metum) do
    create(:metum, organization: organization, title: ScavengerHunt::Game::ANSWER_METUM_NAME)
  end
  let(:clue_metum) do
    create(:metum, organization: organization, title: ScavengerHunt::Game::CLUE_METUM_NAME)
  end
  let(:question_metum) do
    create(:metum, organization: organization, title: ScavengerHunt::Game::QUESTION_METUM_NAME)
  end
  let(:hint_metum) do
    create(:metum, organization: organization, title: ScavengerHunt::Game::HINT_METUM_NAME)
  end
  let(:position_metum) do
    create(:metum, organization: organization, title: ScavengerHunt::Game::CLUE_POSITION_METUM_NAME)
  end

  # Set up the first clue using a base resource
  let(:resource_1) { create(:resource, organization: organization) }

  # ...with two clue representations - only the first should be used
  let!(:clue_1_1) do
    create(:representation, {
      metum: clue_metum,
      ordinality: 1,
      resource: resource_1,
      status: "approved",
      text: "Clue 1 on resource 1"
    })
  end
  let!(:clue_1_2) do
    create(:representation, {
      metum: clue_metum,
      ordinality: 10,
      resource: resource_1,
      status: "approved",
      text: "Clue 2 on resource 1"
    })
  end

  # ...and an answer
  let!(:answer_1) do
    create(:representation, {
      metum: answer_metum,
      resource: resource_1,
      status: "approved",
      text: "Answer #1"
    })
  end

  # ...and a custom question
  let!(:question_1) do
    create(:representation, {
      metum: question_metum,
      resource: resource_1,
      status: "approved",
      text: "This is the first answer:"
    })
  end

  # ... and a high position (to test moving this clue behind other clues)
  let!(:position_1) do
    create(:representation, {
      metum: position_metum,
      resource: resource_1,
      status: "approved",
      text: "100"
    })
  end

  # Set up the second resource
  let(:resource_2) { create(:resource, organization: organization) }

  # ...and a clue
  let!(:clue_2) do
    create(:representation, {
      metum: clue_metum,
      ordinality: 3,
      resource: resource_2,
      status: "approved",
      text: "Clue on resource 2"
    })
  end

  # ...and an answer
  let!(:answer_2) do
    create(:representation, {
      metum: answer_metum,
      resource: resource_2,
      status: "approved",
      text: "Answer #2"
    })
  end

  # ...and a question
  let!(:question_2) do
    create(:representation, {
      metum: question_metum,
      resource: resource_2,
      status: "approved",
      text: "Answer #2 is..."
    })
  end

  # ...and a low position (to test moving this clue before others)
  let!(:position_2) do
    create(:representation, {
      metum: position_metum,
      resource: resource_2,
      status: "approved",
      text: "2"
    })
  end

  # ...and some hints
  let!(:hint_2_1) do
    create(:representation, {
      metum: hint_metum,
      ordinality: 100,
      resource: resource_2,
      status: "approved",
      text: "Hint 1 / 2"
    })
  end

  let!(:hint_2_2) do
    create(:representation, {
      metum: hint_metum,
      ordinality: 10,
      resource: resource_2,
      status: "approved",
      text: "Hint 2 / 2"
    })
  end

  # Set up the last resource
  let(:resource_3) { create(:resource, organization: organization) }

  # ... with a clue
  let!(:clue_3) do
    create(:representation, {
      metum: clue_metum,
      resource: resource_3,
      status: "approved",
      text: "Clue on resource 3"
    })
  end

  # ...but don't give it an approved answer! This resource should not be used
  # to build game questions because it has no approved answer.
  let!(:answer_3) do
    create(:representation, {
      metum: answer_metum,
      resource: resource_3,
      status: "not_approved",
      text: "Answer on rep 3"
    })
  end

  subject { ScavengerHunt::Game.create!(location: location, player: player) }

  it "generates clues for the first approved clue representation with a valid answer by resource" do
    expect(subject.clues.count).to eq(2)
  end

  it "stores clues ordered by extant position meta" do
    expect(subject.clues.first.representation).to eq(clue_2)
    expect(subject.clues.last.representation).to eq(clue_1_1)
  end

  it "uses the answer metum to generate answers" do
    expect(subject.clues.first.answer).to eq(answer_2.text)
    expect(subject.clues.last.answer).to eq(answer_1.text)
  end

  it "uses the question metum to set questions" do
    expect(subject.clues.first.question).to eq(question_2.text)
    expect(subject.clues.last.question).to eq(question_1.text)
  end

  it "generates hints on clues ordered by ordinality" do
    clue = subject.clues.first
    expect(clue.hints.count).to eq(2)
    expect(clue.hints.first.representation).to eq(hint_2_2)
    expect(clue.hints.last.representation).to eq(hint_2_1)
  end
end
