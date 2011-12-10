class Website < ActiveRecord::Base
  belongs_to :user

  validates :url, :presence => true, :format => {with: /^https?:\/\/([A-Z0-9]{1,}\.)?([A-Z0-9]{1,})(\.[A-Z]{2,4}){1,2}$/i}
end
