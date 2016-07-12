class SubstitutionMailer < ApplicationMailer
  def request_sub(substitution, emails, msg)
    @name, @msg = substitution.user.name, msg
    mail bcc: emails, 
         reply_to: substitution.user.email, 
         subject: "[PATROL] #{patrol.user.name} needs a sub on #{patrol.duty_day.date.strftime('%m/%d/%Y')} (#{patrol.patrol_responsibility.name})" 
  end

  def assign_sub(substitution)
    init_assign_accept_reject_members(substitution)
    mail to: substitution.sub.email,
         reply_to: substitution.user.email,
         subject: "[PATROL] #{@sub_for} requests a substitution on #{@date} (#{@responsibility})"
  end

  def reject_sub_request(substitution)
    init_assign_accept_reject_members(substitution)
    mail to: substitution.user.email,
         reply_to: substitution.sub.email,
         subject: "[PATROL] #{@sub_name} has rejected your sub request on #{@date} (#{@responsibility})"
  end

  def accept_sub_request(substitution)
    init_assign_accept_reject_members(substitution)
    mail to: substitution.user.email,
         reply_to: substitution.sub.email,
         subject: "[PATROL] #{@sub_name} has accepted your sub request on #{@date} (#{@responsibility})"
  end

  private 
  
  def init_assign_accept_reject_members(substitution)
    @sub_name = substitution.sub.name 
    @sub_for = substitution.user.name
    @date = substitution.patrol.duty_day.date.strftime('%m/%d/%Y')
    @responsibility = substitution.patrol.patrol_responsibility.name
  end
end
