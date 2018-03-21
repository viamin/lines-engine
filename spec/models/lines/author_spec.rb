require 'spec_helper'

module Lines
  describe Author do
    it 'has a valid factory' do
      expect(FactoryBot.create(:author)).to be_valid
    end

    it 'is invalid without a name' do
      expect(FactoryBot.build(:author, name: nil)).not_to be_valid
    end

    it 'is invalid without an email' do
      expect(FactoryBot.build(:author, email: nil)).not_to be_valid
    end

    it 'is invalid without a description' do
      expect(FactoryBot.build(:author, description: nil)).not_to be_valid
    end

    it 'can not be deleted if belonging to one or more articles' do
      author = FactoryBot.create(:author)
      author.articles << FactoryBot.create(:article)
      # author.destroy.should be false
      expect { author.destroy }.not_to change(Author, :count)
    end
  end
end
