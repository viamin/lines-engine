require 'spec_helper'

module Lines
  describe UserMailer do
    describe 'password_reset' do
      let(:user) { FactoryBot.create(:user) }
      let(:mail) { UserMailer.password_reset(user) }

      before(:each) do
        user.create_reset_digest
      end

      it 'renders the headers' do
        expect(mail.subject).to eq('Forgot your LINES password?')
        expect(mail.to).to eq([user.email])
      end

      it 'renders the body' do
        expect(mail.body.encoded).to match('password')
      end
    end
  end
end
