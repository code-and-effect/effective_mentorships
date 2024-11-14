Rails.application.routes.draw do
  mount EffectiveMentorships::Engine => '/', as: 'effective_mentorships'
end

EffectiveMentorships::Engine.routes.draw do
  scope module: 'effective' do
  end

  namespace :admin do
    resources :mentorship_cycles, except: [:show]
  end
end
