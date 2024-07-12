names = %w[john jane joe jack jill jim jenny jerry jessica]
email_domain = ENV['EMAIL_DOMAIN'] || '@defaultdomain.com' # Fallback in case the env var is not set
emails = names.map { |name| "#{name}@#{email_domain}" }

subjects = [
  'The weather is nice today',
  'I am going to the beach',
  'I have a meeting at 3pm',
  'I am going to the gym',
  'I am going to the movies'
]


emails.each do |sender|
  # The sender must be a confirmed sender in your Postmark account
  sender = ENV['CONFIRMED_SENDER_SIGNATURE'] || 'sender@defaultdomain.com'

  4.times do
    ### The recipients in this seed are not real emails, therefore they will bounce and need to be reactivated before using them as recipients for the next batch ###
    client = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)
    bounces = client.get_bounces
    bounces.each{ |bounce| client.activate_bounce(bounce[:id]) }
    ##############

    recipients = emails.reject { |email| email == sender }.sample(3)
    TestMailer.hello(
      from: sender,
      recipients: recipients,
      subject: subjects.sample(1).first
    ).deliver_now
    puts "Sent email from #{sender} to #{recipients.join(', ')}"
  end
end
