# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
User.create do |user|
	user.email = 'xuhao@rubyfans.com'
	user.username = 'xuhao'
	user.password = 'wtools.cn'
	user.admin = true
end