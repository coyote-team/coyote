# frozen_string_literal: true
# require "spec_helper"

# RSpec.describe ScavengerHunt::Game do
#   include_context "Scavenger Hunt"
#   subject { game }

#   it "generates clues for the first approved clue representation with a valid answer by resource" do
#     expect(subject.clues.count).to eq(2)
#   end

#   it "stores clues ordered by extant position meta" do
#     expect(subject.clues.first.representation).to eq(clue_2)
#     expect(subject.clues.last.representation).to eq(clue_1_1)
#   end

#   it "uses the answer metum to generate answers" do
#     expect(subject.clues.first.answer).to eq(answer_2.text)
#     expect(subject.clues.last.answer).to eq(answer_1.text)
#   end

#   it "uses the question metum to set questions" do
#     expect(subject.clues.first.question).to eq(question_2.text)
#     expect(subject.clues.last.question).to eq(question_1.text)
#   end

#   it "generates hints on clues ordered by ordinality" do
#     clue = subject.clues.first
#     expect(clue.hints.count).to eq(2)
#     expect(clue.hints.first.representation).to eq(hint_2_2)
#     expect(clue.hints.last.representation).to eq(hint_2_1)
#   end

#   it "becomes archived when its underlying representations change" do
#     expect(game.is_archived).to be false
#     question_1.update(text: "Changing this text should archive past games")
#     expect(game.reload.is_archived).to be true
#   end

#   it "becomes archived when its underlying resource changes" do
#     expect(game.is_archived).to be false
#     question_1.resource.update(name: "Changing this text should archive past games")
#     expect(game.reload.is_archived).to be true
#   end

#   it "does not become archived when unimportant representations change" do
#     expect(game.is_archived).to be false
#     position_1.update(text: "10000")
#     expect(game.reload.is_archived).to be false
#   end

#   it "does not become archived when unapproved representations change" do
#     expect(game.is_archived).to be false
#     answer_3.update(text: "This shouldn't change anything, folks!")
#     expect(game.reload.is_archived).to be false
#   end
# end
