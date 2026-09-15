class ActivityLogger
  def self.log(organization:, user:, trackable:, action:, metadata: {})
    ActivityLog.create!(
      organization: organization,
      user: user,
      trackable: trackable,
      action: action,
      metadata: metadata
    )
  end
end