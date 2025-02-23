class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  acts_as_role_restricted
  effective_mentorships_user

  def to_s
    "#{first_name} #{last_name}"
  end
end
