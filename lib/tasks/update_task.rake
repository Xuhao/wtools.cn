namespace :update_task do

  desc "update should_completed_ratio"
  # 定时任务(天，周，季度，月，年）
  # 1，每天执行时间类型是'天'的task），并且查找结束时间刚好是当天的task
  # 2，周，月，季度，年（每周，每月，每季度，每年）
  task :cron_day_task => :environment do
    Task.where("(status != 'closed' AND status != 'completed') OR end_at = #{Date.today}").each do |t|
      t.update_should_completed_ratio
    end
  end


  task :cron_week_task => :environment do
    Task.cron_tasks('week').each do |t|
      t.update_should_completed_ratio
    end
  end


  task :cron_month_task => :environment do
    Task.cron_tasks('month').each do |t|
      t.update_should_completed_ratio
    end
  end

  task :cron_quarter_task => :environment do
    Task.cron_tasks('quarter').each do |t|
      t.update_should_completed_ratio
    end
  end

  task :cron_year_task => :environment do
    Task.cron_tasks('year').each do |t|
      t.update_should_completed_ratio
    end
  end


end
