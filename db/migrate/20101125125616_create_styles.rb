class CreateStyles < ActiveRecord::Migration
  def self.up
    create_table :styles do |t|
      t.integer :user_id,                    :null => false
      t.string  :name,                       :null => false
      t.boolean :name_display,                                :default => 1
      t.boolean :detail_display,                              :default => 1
      t.boolean :evaluation_display,                          :default => 1
      t.boolean :completed_display,                           :default => 1
      t.string  :completed_word_type,                         :default => 'ratio'
      t.boolean :should_completed_display,                    :default => 1
      t.string  :should_completed_word_type,                  :default => 'ratio'
      t.string  :whole_word_type,                             :default => 'ratio'
      t.boolean :done_only_display,                           :default => 1
      t.boolean :log_display,                                 :default => 1
      t.boolean :time_stamp_display,                          :default => 1
      t.boolean :once_ratio_display,                          :default => 1
      t.boolean :aspire_word_display,                         :default => 1
      t.boolean :statistical_evaluation_display,              :default => 1
      t.string  :completed_bgcolor,                           :default => '#6d9e27'
      t.string  :should_completed_bgcolor,                    :default => '#F39814'
      t.string  :whole_bgcolor,                               :default => '#B1D632'
      t.string  :border_color,                                :default => '#666666'
			t.integer :bar_width,                                   :default => 200
			t.integer :bar_height,                                  :default => 20

      t.timestamps
    end
    add_index(:styles, :user_id)
    add_index(:styles, :name)
  end

  def self.down
    drop_table :styles
  end
end
