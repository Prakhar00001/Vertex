class NotificationService
  def self.notify_assignment(task:, actor:)
    return if task.assignee.nil? || task.assignee == actor

    notification = Notification.create!(
      user: task.assignee,
      actor: actor,
      notifiable: task,
      action: "assigned"
    )

    TaskNotificationWorker.perform_async(notification.id)
  end

  def self.notify_comment(comment:, actor:)
    task = comment.task
    recipients = ([task.creator, task.assignee] - [actor]).compact.uniq

    recipients.each do |recipient|
      notification = Notification.create!(
        user: recipient,
        actor: actor,
        notifiable: comment,
        action: "commented"
      )
      TaskNotificationWorker.perform_async(notification.id)
    end
  end
end