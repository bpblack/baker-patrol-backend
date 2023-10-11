class SeasonPolicy < ApplicationPolicy
  def latest?
    user.has_role?(:admin)
  end

  def create?
    user.has_role?(:admin)
  end
end