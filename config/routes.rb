Rails.application.routes.draw do
  mount EffectiveMentorships::Engine => '/', as: 'effective_mentorships'
end

EffectiveMentorships::Engine.routes.draw do
  scope module: 'effective' do
    resources :mentorship_cycles, only: [] do
      resources :mentorship_registrations, except: [:index, :show]
    end

    resources :mentorship_groups, only: [:show]
  end

  namespace :admin do
    resources :mentorship_cycles, except: [:show]
    resources :mentorship_registrations, only: [:index, :edit, :update, :delete]

    resources :mentorship_bulk_groups, only: [:index, :new, :show, :destroy] do
      resources :build, controller: :mentorship_bulk_groups, only: [:show, :update]
    end

    resources :mentorship_groups, except: [:show] do
    end

    resources :mentorship_group_users, except: [:show]
  end
end
