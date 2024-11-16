Rails.application.routes.draw do
  mount EffectiveMentorships::Engine => '/', as: 'effective_mentorships'
end

EffectiveMentorships::Engine.routes.draw do
  scope module: 'effective' do
    resources :mentorship_cycles, only: [] do
      resources :mentorship_registrations, except: [:index]
    end

    resources :mentorship_groups, only: [:show]
  end

  namespace :admin do
    resources :mentorship_cycles, except: [:show]
    resources :mentorship_registrations, except: [:show]

    resources :mentorship_groups, except: [:show] do
      post :archive, on: :member
      post :unarchive, on: :member
      post :bulk_archive, on: :collection
      post :bulk_unarchive, on: :collection
    end

    resources :mentorship_group_users, except: [:show]
  end
end
