require 'spec_helper'

module Lines
  describe User do
    it 'has a valid factory' do
      expect(FactoryBot.create(:user)).to be_valid
    end

    it 'is invalid without an email' do
      expect(FactoryBot.build(:user, email: nil)).not_to be_valid
    end

    it 'is invalid without a password' do
      expect(FactoryBot.build(:user, password: nil)).not_to be_valid
    end
  end
end
