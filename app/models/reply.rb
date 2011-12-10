class Reply < ActiveRecord::Base
  belongs_to :user
  belongs_to :feedback, :counter_cache => true
  belongs_to :reply
  has_many :replies, :dependent => :destroy
  delegate :username, :to => :user
	delegate :current_sign_in_ip, :to => :user, :prefix => true
	validates :content, :presence => true
end
