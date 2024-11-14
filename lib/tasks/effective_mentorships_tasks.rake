namespace :effective_mentorships do

  # bundle exec rake effective_mentorship:seed
  task seed: :environment do
    load "#{__dir__}/../../db/seeds.rb"
  end

end
