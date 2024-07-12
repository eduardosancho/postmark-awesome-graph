class TestMailer < ApplicationMailer
  def hello(from: 'sender@defaultdomain.com', recipients: [], subject: 'Hello from Postmark')
    @subject = subject
    @greeting = 'Hello'

    mail(
      subject: @subject,
      to: recipients,
      from: from,
      track_opens: 'true',
      message_stream: 'outbound')
  end
end
