class StudentMailer < ActionMailer::Base
  default from: 'volypatrol@mtbaker.us',
          reply_to: Rails.application.config.cpr_ior[:email]

  # don't pass model objects since we're queueing emails
  def reminder_email(name, tinyid, reminder, email)
    @name = name
    @signup_url = Rails.application.config.cpr_url + tinyid
    @prefix, subject = (reminder) ? ['This is a reminder that you need to sign up for a','[Mt. Baker] CPR Refresher Reminder'] :
                                               ["It's time to sign up for a", '[Mt. Baker] Sign up for CPR Refresher'] 
    mail(to: email, subject: subject) { |format| format.text } 
  end
  
  def signup_email(name, email, time, location_name, location_address, location_map_link, location_note)
    @name = name
    @cpr_class = time
    @location_name = location_name
    @location_address = location_address
    @location_map_link = location_map_link
    @location_note = location_note
    mail(to: email, subject: '[Mt. Baker] Your CPR Refresher') { |format| format.text }
  end

  def class_changed_email(name, email, time, location_name, location_address, location_map_link, location_note)
    @name = name
    @cpr_class = time
    @location_name = location_name
    @location_address = location_address
    @location_map_link = location_map_link 
    @location_note = location_note   
    mail(to: email, subject: '[Mt. Baker] Your CPR Refresher') { |format| format.text }
  end
end
