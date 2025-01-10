class CreateEffectiveMentorships < ActiveRecord::Migration[6.0]
  def change
    create_table :mentorship_cycles do |t|
      t.string :title

      t.datetime :start_at
      t.datetime :end_at

      t.datetime :registration_start_at
      t.datetime :registration_end_at

      t.integer :max_pairings_mentee

      t.integer :mentorship_groups_count, default: 0
      t.integer :mentorship_registrations_count, default: 0

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :mentorship_groups do |t|
      t.integer :mentorship_cycle_id

      t.string :title

      t.boolean :archived, default: false

      t.string :token

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :mentorship_group_users do |t|
      t.integer :mentorship_cycle_id
      t.integer :mentorship_group_id

      t.string :user_type
      t.integer :user_id

      t.string :mentorship_role

      t.string :name
      t.string :email

      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    create_table :mentorship_registrations do |t|
      t.integer :mentorship_cycle_id
      t.integer :user_id

      t.string :parent_type
      t.integer :parent_id

      t.string :title

      t.boolean :opt_in, default: false
      t.boolean :accept_declaration, default: false

      t.string :mentorship_role

      t.string :category
      t.string :venue
      t.string :location

      t.integer :mentor_multiple_mentees_limit

      t.string :token

      t.datetime :updated_at
      t.datetime :created_at
    end
  end
end
