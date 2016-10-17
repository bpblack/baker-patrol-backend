class GoogleCalendarPolicy < ApplicationPolicy
  def authorize?
    user.google_calendar.nil?
  end

  def create?
    user.google_calendar.nil?
  end

  def calendars?
    !user.google_calendar.nil?
  end

  def select?
    !user.google_calendar.nil?
  end

  def destroy?
    !user.google_calendar.nil?
  end
end
