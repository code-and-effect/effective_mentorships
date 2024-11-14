puts "Running effective_mentorships seeds"

now = Time.zone.now

if Rails.env.test?
  Effective::MentorshipCycle.delete_all
  ActionText::RichText.where(record_type: ['Effective::MentorshipCycle']).delete_all
end

# Build the first MentorshipCycle
cycle = Effective::MentorshipCycle.create!(
  title: "#{now.year} Mentorship",
  start_at: now.beginning_of_year,
  end_at: now.end_of_year,
  registration_start_at: now.beginning_of_year,
  registration_end_at: now.end_of_year,
  rich_text_all_steps_content: "All Steps Content",
)

puts "All Done"
