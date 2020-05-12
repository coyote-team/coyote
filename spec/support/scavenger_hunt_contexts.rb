# frozen_string_literal: true
# RSpec.shared_context "Scavenger Hunt" do
#   # Set up a Scavenger Hunt game
#   let(:organization) { create(:organization) }
#   let(:location) do
#     ScavengerHunt::Location.find_or_initialize_by(organization_id: organization.id).tap { |location| location.update!(tint: "#ff0000") }
#   end
#   let(:player) { ScavengerHunt::Player.create!(ip: "127.0.0.1", user_agent: "test") }

#   # ...include the meta used to identify content in Coyote that powers the game
#   def metum_named(name)
#     organization.meta.find_or_initialize_by(name: name).tap do |meta|
#       meta.update!(instructions: "Test")
#     end
#   end

#   let(:answer_metum) { metum_named(ScavengerHunt::Game::ANSWER_METUM_NAME) }
#   let(:clue_metum) { metum_named(ScavengerHunt::Game::CLUE_METUM_NAME) }
#   let(:question_metum) { metum_named(ScavengerHunt::Game::QUESTION_METUM_NAME) }
#   let(:hint_metum) { metum_named(ScavengerHunt::Game::HINT_METUM_NAME) }
#   let(:position_metum) { metum_named(ScavengerHunt::Game::CLUE_POSITION_METUM_NAME) }

#   # Set up the first clue using a base resource
#   let(:resource_1) { create(:resource, organization: organization) }

#   # ...with two clue representations - only the first should be used
#   let!(:clue_1_1) do
#     create(:representation, {
#       metum:      clue_metum,
#       ordinality: 1,
#       resource:   resource_1,
#       status:     "approved",
#       text:       "Clue 1 on resource 1",
#     })
#   end
#   let!(:clue_1_2) do
#     create(:representation, {
#       metum:      clue_metum,
#       ordinality: 10,
#       resource:   resource_1,
#       status:     "approved",
#       text:       "Clue 2 on resource 1",
#     })
#   end

#   # ...and an answer
#   let!(:answer_1) do
#     create(:representation, {
#       metum:    answer_metum,
#       resource: resource_1,
#       status:   "approved",
#       text:     "Answer #1",
#     })
#   end

#   # ...and a custom question
#   let!(:question_1) do
#     create(:representation, {
#       metum:    question_metum,
#       resource: resource_1,
#       status:   "approved",
#       text:     "This is the first answer:",
#     })
#   end

#   # ... and a high position (to test moving this clue behind other clues)
#   let!(:position_1) do
#     create(:representation, {
#       metum:    position_metum,
#       resource: resource_1,
#       status:   "approved",
#       text:     "100",
#     })
#   end

#   # Set up the second resource
#   let(:resource_2) { create(:resource, organization: organization) }

#   # ...and a clue
#   let!(:clue_2) do
#     create(:representation, {
#       metum:      clue_metum,
#       ordinality: 3,
#       resource:   resource_2,
#       status:     "approved",
#       text:       "Clue on resource 2",
#     })
#   end

#   # ...and an answer
#   let!(:answer_2) do
#     create(:representation, {
#       metum:    answer_metum,
#       resource: resource_2,
#       status:   "approved",
#       text:     "Answer #2",
#     })
#   end

#   # ...and a question
#   let!(:question_2) do
#     create(:representation, {
#       metum:    question_metum,
#       resource: resource_2,
#       status:   "approved",
#       text:     "Answer #2 is...",
#     })
#   end

#   # ...and a low position (to test moving this clue before others)
#   let!(:position_2) do
#     create(:representation, {
#       metum:    position_metum,
#       resource: resource_2,
#       status:   "approved",
#       text:     "2",
#     })
#   end

#   # ...and some hints
#   let!(:hint_2_1) do
#     create(:representation, {
#       metum:      hint_metum,
#       ordinality: 100,
#       resource:   resource_2,
#       status:     "approved",
#       text:       "Hint 1 / 2",
#     })
#   end

#   let!(:hint_2_2) do
#     create(:representation, {
#       metum:      hint_metum,
#       ordinality: 10,
#       resource:   resource_2,
#       status:     "approved",
#       text:       "Hint 2 / 2",
#     })
#   end

#   # Set up the last resource
#   let(:resource_3) { create(:resource, organization: organization) }

#   # ... with a clue
#   let!(:clue_3) do
#     create(:representation, {
#       metum:    clue_metum,
#       resource: resource_3,
#       status:   "approved",
#       text:     "Clue on resource 3",
#     })
#   end

#   # ...but don't give it an approved answer! This resource should not be used
#   # to build game questions because it has no approved answer.
#   let!(:answer_3) do
#     create(:representation, {
#       metum:    answer_metum,
#       resource: resource_3,
#       status:   "not_approved",
#       text:     "Answer on rep 3",
#     })
#   end

#   let!(:game) { ScavengerHunt::Game.create!(location: location, player: player) }
# end
