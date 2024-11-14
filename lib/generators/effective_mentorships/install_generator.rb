module EffectiveMentorships
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc 'Creates an EffectiveMentorships initializer in your application.'

      source_root File.expand_path('../../templates', __FILE__)

      def self.next_migration_number(dirname)
        if not ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          '%.3d' % (current_migration_number(dirname) + 1)
        end
      end

      def copy_initializer
        template ('../' * 3) + 'config/effective_mentorship.rb', 'config/initializers/effective_mentorship.rb'
      end

      def copy_locale
        template ('../' * 3) + 'config/locales/effective_mentorships.en.yml', 'config/locales/effective_mentorships.en.yml'
      end

      def create_migration_file
        migration_template ('../' * 3) + 'db/migrate/101_create_effective_mentorships.rb.erb', 'db/migrate/create_effective_mentorships.rb'
      end

      def copy_mailer_preview
        mailer_preview_path = (Rails.application.config.action_mailer.preview_path rescue nil)

        if mailer_preview_path.present?
          template 'effective_mentorships_mailer_preview.rb', File.join(mailer_preview_path, 'effective_mentorships_mailer_preview.rb')
        else
          puts "couldn't find action_mailer.preview_path. Skipping effective_mentorships_mailer_preview."
        end
      end

    end
  end
end
