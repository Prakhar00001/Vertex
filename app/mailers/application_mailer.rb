class ApplicationMailer < ActionMailer::Base
  default from: "notifications@vertex.io"
  layout "mailer"
end