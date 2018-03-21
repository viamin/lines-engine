require 'spec_helper'

module Lines
  describe Article do
    it 'has a valid factory' do
      expect(FactoryBot.create(:article)).to be_valid
    end

    it 'is invalid without a title' do
      expect(FactoryBot.build(:article, title: nil)).not_to be_valid
    end

    it 'is invalid without content' do
      expect(FactoryBot.build(:article, content: nil)).not_to be_valid
    end

    # it "is invalid with neither hero_image nor short_hero_image " do
    #   FactoryBot.build(:article, hero_image: nil, short_hero_image: nil).should_not be_valid
    # end

    # it "is invalid with both a hero_image and a short_hero_image" do
    #   FactoryBot.build(:article, short_hero_image: 1 ).should_not be_valid
    # end

    it 'is invalid without one or more authors' do
      expect(FactoryBot.build(:article, author_ids: nil)).not_to be_valid
    end

    it 'is valid with tags' do
      a = FactoryBot.create(:article_with_tags)
      expect(a).to be_valid
      expect(a.tag_list).to eq(%w[tag1 tag2])
    end
  end
end
