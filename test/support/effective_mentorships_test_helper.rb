module EffectiveMentorshipsTestHelper

  def sign_in(user = create_user!)
    login_as(user, scope: :user); user
  end

  def as_user(user, &block)
    sign_in(user); yield; logout(:user)
  end

  def assert_email(count: 1, &block)
    before = ActionMailer::Base.deliveries.length
    yield
    after = ActionMailer::Base.deliveries.length

    assert (after - before == count), "expected one email to have been delivered"
  end

  def assert_no_email(&block)
    before = ActionMailer::Base.deliveries.length
    retval = yield
    after = ActionMailer::Base.deliveries.length

    diff = (after - before)

    assert (diff == 0), "(assert_no_email) #{diff} unexpected emails delivered"
    retval
  end

end
