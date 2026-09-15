class UserMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @user = @notification.user
    @actor = @notification.actor
    mail(to: @user.email, subject: "New notification on Vertex")
  end
end