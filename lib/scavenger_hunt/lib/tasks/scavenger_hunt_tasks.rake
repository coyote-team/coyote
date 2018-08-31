namespace :scavenger_hunt do
  desc "Seed Coyote with Scavenger Hunt data"
  task seed: :environment do
    meta = [
      {
        title: ScavengerHunt::Game::ANSWER_METUM_NAME,
        instructions: "A scavenger hunt answer that users must enter when they have found the clue",
      },
      {
        title: ScavengerHunt::Game::CLUE_METUM_NAME,
        instructions: "A scavenger hunt clue informing players what they're searching for",
      },
      {
        title: ScavengerHunt::Game::HINT_METUM_NAME,
        instructions: "A scavenger hunt hint helping players to identify a difficult clue",
      },
    ]

    ::Organization.all.each do |organization|
      puts "Creating Location for #{organization.title}"
      location = ScavengerHunt::Location.find_or_initialize_by(organization: organization)
      location.tint = "#ff00ff"
      location.save!

      meta.each do |attributes|
        metum = Metum.find_or_initialize_by(
          title: attributes[:title],
          organization: organization
        )
        puts %{Creating metum "#{metum.title}" for #{organization.title}}
        metum.update_attributes!(attributes)
      end
    end

    survey_questions = [
      {
        text: "Was it fun?",
        options: ["Yes", "No", "Kind of"]
      },
      {
        text: "Was it hard?",
        options: ["Yes", "No", "Kind of"]
      },
      {
        text: "Would you play this game again?",
        options: ["Yes", "No", "Maybe"]
      },
      {
        text: "What would you change about the game?"
      }
    ]

    survey_questions.each do |attributes|
      question = ScavengerHunt::SurveyQuestion.find_or_initialize_by(text: attributes[:text])
      puts %{Creating survey question "#{question.text}"}
      question.update_attributes!(attributes)
    end
  end
end
