class ContactMailer < ActionMailer::Base
  default from: "\"#{ENV['ADMIN_NAME']}\" <#{ENV['ADMIN_EMAIL']}>"

  def invite(contact)
    @contact = contact
    mail(:to => "\"#{@contact.name}\" <#{@contact.email}>", :subject => "Big Ten Tournament Bracket")
  end
end
