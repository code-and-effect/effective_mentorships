module EffectiveMentorships
  class Engine < ::Rails::Engine
    engine_name 'effective_mentorships'

    # Set up our default configuration options.
    initializer 'effective_mentorships.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_mentorships.rb")
    end

    # Include concerns and allow any ActiveRecord object to call it
    initializer 'effective_mentorships.active_record' do |app|
      app.config.to_prepare do
        ActiveRecord::Base.extend(EffectiveMentorshipsUser::Base)
        ActiveRecord::Base.extend(EffectiveMentorshipsGroup::Base)
        ActiveRecord::Base.extend(EffectiveMentorshipsRegistration::Base)
      end
    end

  end
end
