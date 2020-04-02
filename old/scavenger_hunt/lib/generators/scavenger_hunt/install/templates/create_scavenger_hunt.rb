# frozen_string_literal: true

class CreateScavengerHunt < ActiveRecord::Migration[5.2]
  def change
    create_table :scavenger_hunt_players do |t|
      t.string :email
      t.string :name
      t.string :user_agent, null: false
      t.inet :ip, null: false
      t.timestamps
    end

    create_table :scavenger_hunt_locations do |t|
      t.belongs_to :organization, null: false
      t.integer :position, null: false
      t.string :tint, null: false
    end

    create_table :scavenger_hunt_games do |t|
      t.belongs_to :location, null: false
      t.belongs_to :player, null: false
      t.timestamp :ended_at
      t.timestamps
    end

    create_table :scavenger_hunt_clues do |t|
      t.belongs_to :game, null: false
      t.belongs_to :representation, null: false
      t.integer :position, null: false
      t.timestamp :started_at
      t.timestamp :ended_at
      t.timestamps
    end

    create_table :scavenger_hunt_hints do |t|
      t.belongs_to :clue, null: false
      t.belongs_to :representation, null: false
      t.integer :position, null: false
      t.timestamp :used_at
      t.timestamps
    end

    create_table :scavenger_hunt_answers do |t|
      t.belongs_to :clue, null: false
      t.belongs_to :resource, null: false
      t.boolean :is_correct, null: false
      t.timestamps
    end

    create_table :scavenger_hunt_survey_questions do |t|
      t.integer :position, null: false
      t.string :text, null: false
      t.json :options
    end

    create_table :scavenger_hunt_survey_answers do |t|
      t.belongs_to :player, null: false
      t.belongs_to :survey_question, null: false
      t.string :answer
    end
  end
end
