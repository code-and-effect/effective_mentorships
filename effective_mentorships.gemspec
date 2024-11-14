$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'effective_mentorships/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'effective_mentorships'
  spec.version     = EffectiveMentorships::VERSION
  spec.authors     = ['Code and Effect']
  spec.email       = ['info@codeandeffect.com']
  spec.homepage    = 'https://github.com/code-and-effect/effective_mentorships'
  spec.summary     = 'Mentorship matching for mentors and mentees rails engine'
  spec.description = 'Mentorship matching for mentors and mentees rails engine'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*"] + ['MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 6.0.0'
  spec.add_dependency 'effective_bootstrap'
  spec.add_dependency 'effective_datatables', '>= 4.0.0'
  spec.add_dependency 'effective_email_templates'
  spec.add_dependency 'effective_resources'
  spec.add_dependency 'wicked'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'devise'
  spec.add_development_dependency 'haml-rails'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'effective_developer'
  spec.add_development_dependency 'effective_roles'
  spec.add_development_dependency 'psych', '< 4'
end
