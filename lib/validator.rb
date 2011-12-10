class ColorValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
		record.errors.add attribute, :invalid_color unless value =~ /^#[0-9a-f]{3}$|^#[0-9a-f]{6}$/i
  end
end
