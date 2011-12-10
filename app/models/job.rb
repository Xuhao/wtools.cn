class Job < Task
  after_save :create_task_logs, :if => proc {|task| task.log_able && task.task_logs.empty? }
  after_update :rebuild_logs, :if => proc {|task| task.log_able }
end