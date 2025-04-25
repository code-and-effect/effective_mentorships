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
      t.integer :mentorship_bulk_group_id

      t.string :title

      t.datetime :published_start_at
      t.datetime :published_end_at
      t.datetime :last_notified_at

      t.string :token

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :mentorship_groups, :mentorship_cycle_id, if_not_exists: true
    add_index :mentorship_groups, :token, if_not_exists: true

    create_table :mentorship_group_users do |t|
      t.integer :mentorship_cycle_id
      t.integer :mentorship_group_id

      t.string :mentorship_registration_type
      t.integer :mentorship_registration_id

      t.string :user_type
      t.integer :user_id

      t.string :mentorship_role

      t.string :name
      t.string :email

      t.integer :position

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :mentorship_group_users, [:user_type, :user_id], if_not_exists: true
    add_index :mentorship_group_users, :mentorship_group_id, if_not_exists: true
    add_index :mentorship_group_users, :position, if_not_exists: true

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

    add_index :mentorship_registrations, :mentorship_cycle_id, if_not_exists: true
    add_index :mentorship_registrations, :user_id, if_not_exists: true
    add_index :mentorship_registrations, :token, if_not_exists: true

    create_table :mentorship_bulk_groups do |t|
      t.integer :mentorship_cycle_id
      t.integer :mentorship_groups_count, default: 0

      t.boolean :email_form_skip, default: false
      t.text :wizard_steps

      t.string :token

      t.string :job_status
      t.datetime :job_started_at
      t.datetime :job_ended_at
      t.text :job_error

      t.datetime :updated_at
      t.datetime :created_at
    end

    add_index :mentorship_bulk_groups, :mentorship_cycle_id, if_not_exists: true
    add_index :mentorship_bulk_groups, :token, if_not_exists: true
  end
end
