class Contact
  include ActiveAttr::Model

  attribute :name
  attribute :email
  attribute :invite_by

  def self.session
    GoogleDrive.login(ENV['GMAIL_USERNAME'], ENV['GMAIL_PASSWORD'])
  end

  def self.all
    ws = session.spreadsheet_by_key(ENV['CONTACTS_SPREADSHEET_KEY']).worksheets[0]
    ws.rows[1..-1].collect do |row|
      new :name => row[0], :email => row[1], :invite_by => row[2]
    end
  end

  def invite
    ContactMailer.invite(self).deliver
  end
end
