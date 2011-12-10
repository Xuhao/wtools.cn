#require 'ostruct'
class Style < ActiveRecord::Base
	belongs_to :user
  has_many :tasks, :dependent => :nullify

	validates :name, :presence => true, :uniqueness => { :scope => :user_id }
  validates :bar_width, :numericality => {:greater_than_or_equal_to => 0}
  validates :bar_height, :numericality => {:greater_than_or_equal_to => 0}
  validates :completed_bgcolor, :color => true
  validates :should_completed_bgcolor, :color => true
  validates :whole_bgcolor, :color => true
  validates :border_color, :color => true

  class << self
    # => 虚拟的style,给没有指定style的task用
    def virtual_style
			@virtual_style ||= new
      #@virtual_style ||= OpenStruct.new(new.attributes)
			#      # => 在下面重置属性可以用来测试
			#      @virtual_style.time_stamp_display = true
			#      @virtual_style.completed_word_type = 'time_stamp'
			#      @virtual_style.should_completed_word_type = 'time_stamp'
			#      @virtual_style.whole_word_type = 'time_stamp'
			#      #@virtual_style.name_display = false
			#      #@virtual_style.detail_display = false
			#      @virtual_style.aspire_word_display = true
			#      @virtual_style.statistical_evaluation_display = true
			#      @virtual_style
    end
  end

end
