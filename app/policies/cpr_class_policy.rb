class CprClassPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin) || user.has_role?(:cprinstructor)
  end

  def resize?
    user.has_role?(:admin) || user.has_role?(:cprinstructor)
  end
end