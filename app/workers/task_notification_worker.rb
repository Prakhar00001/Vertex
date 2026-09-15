class TaskNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :notifications, retry: 3

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    UserMailer.with(notification: notification).notification_email.deliver_now
  end
end