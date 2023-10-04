class CprClassPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin) || user.has_role?(:cprior) || user.has_role?(:cprinstructor)
  end

  def update?
    user.has_role?(:admin) || user.has_role?(:cprior) || user.has_role?(:cprinstructor)
  end
end