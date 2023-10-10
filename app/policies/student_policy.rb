class StudentPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin) || user.has_role?(:cprior) || user.has_role?(:cprinstructor)
  end

  def create?
    user.has_role?(:admin) || user.has_role?(:cprior)
  end

  def remind?
    user.has_role?(:admin) || user.has_role?(:cprior)
  end

  def update?
    user.has_role?(:admin) || user.has_role?(:cprior)
  end

  def remove?
    user.has_role?(:admin) || user.has_role?(:cprior)
  end
end