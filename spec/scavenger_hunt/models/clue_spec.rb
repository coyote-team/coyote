# frozen_string_literal: true
# RSpec.describe ScavengerHunt::Clue do
#   include_context "Scavenger Hunt"

#   let(:clue) { game.clues.first }
#   let(:hints) { clue.hints.order(:position) }

#   it "returns the next unused clue" do
#     expect(clue.first_hint).to eq(hints.first)

#     hints.first.update_attribute(:used_at, Time.now)
#     expect(clue.first_hint).to eq(hints.last)
#     expect(game.reload.penalty_time_in_seconds).to eq(ScavengerHunt::Hint::PENALTY)
#   end
# end
