module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    #sentence = "#{pluralize(resource.errors.count, "error")} prohibited this #{resource_name} from being saved:"
		sentence = I18n.t("activerecord.errors.template.header", :count => resource.errors.count, :model => User.model_name.human)

    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
end