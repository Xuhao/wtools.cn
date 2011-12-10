require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "delay_remind" do
    mail = UserMailer.delay_remind
    assert_equal "Delay remind", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
