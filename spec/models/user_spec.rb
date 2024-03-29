require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#valid?' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should allow_value('name@email.com').for(:email) }
    it { should_not allow_value('name.email.com').for(:email) }
    it { should_not allow_value('name@email').for(:email) }
    it { should_not allow_value('name@').for(:email) }
    it { should_not allow_value('@email.com').for(:email) }
  end
end
