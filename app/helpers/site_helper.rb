require 'ostruct'
module SiteHelper
  extend ActiveSupport::Memoizable
	# == 日志等级对照表，数组第一个数字是数据库内容，第二个是文字描述，第三个是样式名称
	LEVEL_WROD = [[1,'很好','very-good'], [2,'良好','good'], [3,'一般','ordinary'], [4,'很差','bad']] 

  # => 根据是否显示任务名称和是否显示“详细”按钮来确定进度条占的栏位数。
  def colspan(style)
    colspan_num = 0
    colspan_num += 1 unless name_display(style)
    colspan_num += 1 unless detail_display(style)
		colspan_num.zero? ? nil : %! colspan="#{colspan_num}"!
  end

	# => views/site/_new.html.erb模版中判断是不是为首页渲染
	def for_index?
		controller.controller_name == 'site' and controller.action_name == 'new_apps'
	end

  def name_display(style)
    style.name_display ? '<td></td>' : nil
  end

  def detail_display(style)
		style.detail_display ? '<td></td>' : nil
  end

  # => 分类统计评价
  def statistical(logs)
    words = (1..4).inject([]) do |arr,level|
      current_rate = logs.select{|x| x.evaluation == level}.sum(&:ratio)
      arr << "#{level_to_word(level)}(<span>#{percentize(current_rate)}</span>)"
    end
    words * '，'
  end

  # => 评价等级文字描述
  def level_to_word(level)
		if the_level = LEVEL_WROD.assoc(level)
			%~<b class="#{the_level[2]}">#{the_level[1]}</b>~
		end
  end

  # => 评价等级图片
  def level_to_img(level,options)
		if the_level = LEVEL_WROD.assoc(level)
			image_tag("level#{level}.png",{:alt => the_level[1], :title => the_level[1]}.merge!(options))
		end
	end

	# => 评价等级选择列表
	def level_options(current_level)
		LEVEL_WROD.inject('') { |options, level| options << %~<option value="#{level[0]}"#{ 'selected="selected"' if current_level == level[0]}>#{level[1]}</option>~ }
	end


	# => 已完成进度条上面的文字说明类型
	def completed_word_type(task)
		case task._style.completed_word_type
		when 'ratio'      then percentize(task.ratio)
		when 'time_stamp' then %!#{TaskLog.done_size(task,:done => true)}#{t("words.#{task.time_type}")}!
		else                   nil
		end
	end

	# => 应完成进度条上面的文字说明类型
	def should_completed_word_type(task)
		case task._style.should_completed_word_type
		when 'ratio'      then percentize(task.should_completed_ratio)
		when 'time_stamp' then %!#{(task.time_num * (task.should_completed_ratio.to_f/100)).round}#{t("words.#{task.time_type}")}!
		else                   nil
		end
	end

	# => 整个进度条上面的文字说明类型
	def whole_word_type(task)
		case task._style.whole_word_type
		when 'ratio'      then '100%'
		when 'time_stamp' then %!#{task.time_num}#{t("words.#{task.time_type}")}!
		else                   nil
		end
	end

end
