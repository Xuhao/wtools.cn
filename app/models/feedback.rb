class Feedback < ActiveRecord::Base
  default_scope order('created_at DESC')

	belongs_to :user
  has_many :replies, :dependent => :destroy
  delegate :username, :to => :user

  validates :title, :presence => true, :uniqueness => { :messages => '已有人提交了相同的反馈！' }
  validates :content, :presence => true
  validates :user_id, :presence => true

  paginates_per 5
end
