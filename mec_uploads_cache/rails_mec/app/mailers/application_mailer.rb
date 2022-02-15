# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@example.com'
  layout 'mailer'
end
