EffectiveMentorships.setup do |config|
  # Layout Settings
  # Configure the Layout per controller, or all at once
  config.layout = {
    mentorships: 'application',
    admin: 'admin'
  }

  # Mentorship Class Settings
  # Configure the class responsible for the mentorships
  config.mentorship_group_class_name = 'MentorshipGroup'
  config.mentorship_registration_class_name = 'MentorshipRegistration'

  # Mailer Settings
  # Please see config/initializers/effective_resources.rb for default effective_* gem mailer settings
  #
  # Configure the class responsible to send e-mails.
  # config.mailer = 'Effective::MentorshipMailer'
  #
  # Override effective_resource mailer defaults
  #
  # config.parent_mailer = nil      # The parent class responsible for sending emails
  # config.deliver_method = nil     # The deliver method, deliver_later or deliver_now
  # config.mailer_layout = nil      # Default mailer layout
  # config.mailer_sender = nil      # Default From value
  # config.mailer_froms = nil       # Default Froms collection
  # config.mailer_admin = nil       # Default To value for Admin correspondence
  # config.mailer_subject = nil     # Proc.new method used to customize Subject
  #
  # All mailers work through effective_email_templates
end
