class UserPolicy < ApplicationPolicy
  def update?
    user.id == record.id
  end

  def extra?
    user.id == record.id
  end

  def email_new?
    user.has_role?(:admin)
  end
end
