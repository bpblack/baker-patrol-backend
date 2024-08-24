class CprYearPolicy < ApplicationPolicy
    def latest?
      user.has_role?(:admin) || user.has_role?(:cprior)
    end

    def index?
      user.has_role?(:admin) || user.has_role?(:cprior)
    end
  
    def create?
      user.has_role?(:admin) || user.has_role?(:cprior)
    end
  end