class Question < ActiveRecord::Base
  scope :get_by, lambda { |order, limit| order(order).limit(limit || 20) }

  validates :name, :presence => true, :uniqueness => true
  validates :type, :presence => true
  validates :answer, :presence => true
end
