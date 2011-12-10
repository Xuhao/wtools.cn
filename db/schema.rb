# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110421080404) do

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.string   "type",                         :null => false
    t.string   "title",                        :null => false
    t.text     "content",                      :null => false
    t.integer  "replies_count", :default => 0
    t.integer  "agree_num",     :default => 0
    t.integer  "against_num",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedbacks", ["type"], :name => "index_feedbacks_on_type"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "ips", :force => true do |t|
    t.string   "ip"
    t.datetime "created_at"
  end

  add_index "ips", ["created_at"], :name => "index_ips_on_created_at"
  add_index "ips", ["ip"], :name => "index_ips_on_ip"

  create_table "messages", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "content",    :null => false
    t.string   "target",     :null => false
    t.datetime "created_at"
  end

  add_index "messages", ["content"], :name => "index_messages_on_content"
  add_index "messages", ["target"], :name => "index_messages_on_target"
  add_index "messages", ["title"], :name => "index_messages_on_title"

  create_table "questions", :force => true do |t|
    t.string   "type",                      :null => false
    t.string   "name",                      :null => false
    t.text     "answer",                    :null => false
    t.integer  "hits",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["name"], :name => "index_questions_on_name"
  add_index "questions", ["type"], :name => "index_questions_on_type"

  create_table "replies", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "feedback_id", :null => false
    t.integer  "reply_id"
    t.string   "content",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "replies", ["feedback_id"], :name => "index_replies_on_feedback_id"

  create_table "styles", :force => true do |t|
    t.integer  "user_id",                                               :null => false
    t.string   "name",                                                  :null => false
    t.boolean  "name_display",                   :default => true
    t.boolean  "detail_display",                 :default => true
    t.boolean  "evaluation_display",             :default => true
    t.boolean  "completed_display",              :default => true
    t.string   "completed_word_type",            :default => "ratio"
    t.boolean  "should_completed_display",       :default => true
    t.string   "should_completed_word_type",     :default => "ratio"
    t.string   "whole_word_type",                :default => "ratio"
    t.boolean  "done_only_display",              :default => true
    t.boolean  "log_display",                    :default => true
    t.boolean  "time_stamp_display",             :default => true
    t.boolean  "once_ratio_display",             :default => true
    t.boolean  "aspire_word_display",            :default => true
    t.boolean  "statistical_evaluation_display", :default => true
    t.string   "completed_bgcolor",              :default => "#6d9e27"
    t.string   "should_completed_bgcolor",       :default => "#F39814"
    t.string   "whole_bgcolor",                  :default => "#B1D632"
    t.string   "border_color",                   :default => "#666666"
    t.integer  "bar_width",                      :default => 200
    t.integer  "bar_height",                     :default => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "styles", ["name"], :name => "index_styles_on_name"
  add_index "styles", ["user_id"], :name => "index_styles_on_user_id"

  create_table "task_logs", :force => true do |t|
    t.integer  "task_id",                       :null => false
    t.boolean  "done",       :default => false
    t.date     "done_at"
    t.integer  "ratio",      :default => 0
    t.string   "content"
    t.integer  "evaluation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_logs", ["task_id"], :name => "index_task_logs_on_task_id"

  create_table "tasks", :force => true do |t|
    t.string   "type",                                         :null => false
    t.integer  "user_id",                                      :null => false
    t.integer  "style_id"
    t.integer  "category_id",            :default => 1
    t.string   "name",                                         :null => false
    t.string   "description"
    t.integer  "time_num",                                     :null => false
    t.string   "time_type",                                    :null => false
    t.date     "begin_at",                                     :null => false
    t.date     "end_at",                                       :null => false
    t.date     "last_show_at"
    t.boolean  "log_able",               :default => false,    :null => false
    t.string   "aspire_word"
    t.boolean  "show_control",           :default => false
    t.string   "show_site"
    t.boolean  "sms_alert",              :default => false,    :null => false
    t.boolean  "email_alert",            :default => false,    :null => false
    t.integer  "delay_for_alert"
    t.integer  "completed_ratio",        :default => 0
    t.integer  "should_completed_ratio", :default => 0
    t.string   "status",                 :default => "normal", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open",                   :default => true
    t.boolean  "email_notice",           :default => true
  end

  add_index "tasks", ["name"], :name => "index_tasks_on_name"
  add_index "tasks", ["status"], :name => "index_tasks_on_status"
  add_index "tasks", ["type"], :name => "index_tasks_on_type"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "user_logs", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "log_type",     :null => false
    t.integer  "relation_id"
    t.integer  "gold_count"
    t.string   "content",      :null => false
    t.string   "query_string"
    t.datetime "created_at",   :null => false
  end

  add_index "user_logs", ["user_id"], :name => "index_user_logs_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",         :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",         :null => false
    t.string   "password_salt",                       :default => "",         :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.string   "locale",                              :default => "zh-CN"
    t.string   "phone_num"
    t.boolean  "admin",                               :default => false,      :null => false
    t.string   "app_codes",                           :default => "job,plan"
    t.integer  "gold_count",                          :default => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "has_read_message_ids"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "default_avatar",                      :default => "local"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "websites", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "url",         :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "websites", ["url"], :name => "index_websites_on_url"
  add_index "websites", ["user_id"], :name => "index_websites_on_user_id"

end
