# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def send_when_succeeded(mail, file)
    @file = file
    mail to: mail, subject: '転送完了'
  end

  def send_when_failed(mail, file)
    @file = file
    mail to: mail, subject: '転送失敗'
  end
end
