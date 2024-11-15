Rails.application.routes.draw do
  mount EffectiveMentorships::Engine => '/', as: 'effective_mentorships'
end

EffectiveMentorships::Engine.routes.draw do
  scope module: 'effective' do
    resources :mentorship_cycles, only: [] do
      resources :mentorship_registrations, except: [:index]
    end
  end

  namespace :admin do
    resources :mentorship_cycles, except: [:show]
  end
end
