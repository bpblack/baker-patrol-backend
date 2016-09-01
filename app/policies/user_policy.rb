class UserPolicy < ApplicationPolicy
  def extra?
    user.id == record.id
  end
end
