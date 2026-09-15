module Tasks
  class TaskReorderService
    def initialize(task:, new_status:, new_position:)
      @task = task
      @new_status = new_status
      @new_position = new_position.to_i
      @project = task.project
    end

    def call
      return false unless Task::STATUSES.include?(@new_status)

      Task.transaction do
        if @task.status != @new_status
          @task.update!(status: @new_status, position: @new_position)
        else
          @task.update!(position: @new_position)
        end
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
end