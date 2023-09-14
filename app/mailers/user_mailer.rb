class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Mt. Baker Patrol Password Reset"
  end

  def new_user(user)
    @user = user
    mail to: @user.email, subject: "Mt Baker Patrol Account Created"
  end

end
