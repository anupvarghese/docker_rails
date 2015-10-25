require 'test_helper'

describe User do
  let(:user) { users(:one) }

  it "must be valid" do
    user.must_be :valid?
  end

  it "must not have empty name" do
    user.name = nil
    user.wont_be :valid?
  end
end
