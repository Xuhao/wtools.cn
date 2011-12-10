class Plan < Task
  before_validation :set_log_able
  after_update :rebuild_logs

  private
  def set_log_able
    self.log_able = true
  end

end
