# To change this template, choose Tools | Templates
# and open the template in the editor.

class Integer
  # => 季节
  def quarter
    (self * 3).months
  end

		# == 将0转换成nil
  def zero_to_nil
    zero? ? nil : self
  end
end
