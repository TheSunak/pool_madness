class UserMailer < ActionMailer::Base
  default from: "\"Brackupify\" <#{ENV['ADMIN_EMAIL']}>"

  def welcome_message(user)
    @user = user
    mail(:to => "\"#{user.name}\" <#{user.email}>", :subject => "Thanks for Registering")
  end

  def last_chance(user)
    @user = user
    mail(:to => "\"#{user.name}\" <#{user.email}>", :subject => "Last Chance to fill out a March Madness Bracket")
  end

  def all_set(user)
    @user = user
    mail(:to => "\"#{user.name}\" <#{user.email}>", :subject => "Thanks for your bracket entry")
  end
end
