# frozen_string_literal: true

namespace :scavenger_hunt do
  desc "Seed Coyote with Scavenger Hunt data"
  task seed: :environment do
    meta = [
      {
        title:        ScavengerHunt::Game::ANSWER_METUM_NAME,
        instructions: "A scavenger hunt answer that users must enter when they have found the clue",
      },
      {
        title:        ScavengerHunt::Game::CLUE_METUM_NAME,
        instructions: "A scavenger hunt clue informing players what they're searching for",
      },
      {
        title:        ScavengerHunt::Game::CLUE_POSITION_METUM_NAME,
        instructions: "The order of a clue within the game. Set text to a lower number to move the clue up front.",
      },
      {
        title:        ScavengerHunt::Game::HINT_METUM_NAME,
        instructions: "A scavenger hunt hint helping players to identify a difficult clue",
      },
      {
        title:        ScavengerHunt::Game::QUESTION_METUM_NAME,
        instructions: "The prompt instructing a player on how to enter an answer to a clue. Defaults to 'I think it is...' if nothing is provided on this resource.",
      },
    ]

    ::Organization.all.each do |organization|
      puts "Creating Location for #{organization.title}"
      location = ScavengerHunt::Location.find_or_initialize_by(organization: organization)
      location.tint = "#ff00ff"
      location.save!

      meta.each do |attributes|
        metum = Metum.find_or_initialize_by(
          title:        attributes[:title],
          organization: organization,
        )
        puts %(Creating metum "#{metum.title}" for #{organization.title})
        metum.update!(attributes)
      end
    end

    survey_questions = [
      {
        text:    "Was it fun?",
        options: ["Yes", "No", "Kind of"],
      },
      {
        text:    "Was it hard?",
        options: ["Yes", "No", "Kind of"],
      },
      {
        text:    "Would you play it again?",
        options: ["Yes", "No", "Maybe"],
      },
      {
        text: "What would you change?",
      },
    ]

    survey_questions.each do |attributes|
      question = ScavengerHunt::SurveyQuestion.find_or_initialize_by(text: attributes[:text])
      puts %(Creating survey question "#{question.text}")
      question.update!(attributes)
    end
  end
end
