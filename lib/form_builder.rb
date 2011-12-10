class ActionView::Helpers::FormBuilder
  include ActionView::Helpers::FormOptionsHelper
  # => 增加单选按钮组Helper方法,通过加'radio_'和'label_'前缀来分别为radio,label设置HTML属性。
  # 如：label_class为label设置class属性
  def radio_group(method, tag_values, checked = nil, options = {})
    options = objectify_options(options)
    radio_options, label_options = {}, {}
    options.keys.each do |key|
      radio_options[key.to_s.gsub('radio_', '').to_sym] = options[key] if key.to_s.include?('radio_')
      label_options[key.to_s.gsub('label_', '').to_sym] = options[key] if key.to_s.include?('label_')
    end
    options.delete_if { |key, value| key.to_s.include?('radio_') || key.to_s.include?('label_') }
    # => 设置默认值，如果记录还未保存就优先设置成指定的值，否则以数据库的值有限
    object = options[:object]
    checked_value = object.new_record? ? (checked || object.__send__(method)) : (object.__send__(method) || checked)
    if String === tag_values
      @template.radio_button(@object_name, method, tag_values, options.merge!(radio_options))
    else
      tag_values = tag_values.to_a if Hash === tag_values
      options_for_radio = tag_values.inject([]) do |buttons, element|
        text, value = option_text_and_value(element)
        label_text = (text == value ? I18n.t("words.#{text}", :default => text) : text)
        buttons << @template.radio_button(@object_name, method, value, options.merge(radio_options).merge({:checked => value == checked_value}))
        buttons << @template.label(@object_name, method, label_text, options.merge(label_options).merge({:value => value}))
      end
      options_for_radio.join("\n")
    end
  end

  # => 复写label,加上"comm"样式
  def label(method, text = nil, options = {:class => 'comm'})
    @template.label(@object_name, method, text, objectify_options(options))
  end
end