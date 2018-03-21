require 'spec_helper'

module Lines
  describe Picture do
    it 'has a valid factory' do
      expect(FactoryBot.create(:picture)).to be_valid
    end

    it 'should trigger :update_used_images after save' do
      pic = FactoryBot.create(:picture)
      article = FactoryBot.create(:article, content: "![Alt text](#{pic.image.url})")
      expect(article).to receive(:update_used_images)
      article.save
    end

    it 'should belong to article after used in article.content' do
      pic = FactoryBot.create(:picture)
      article = FactoryBot.create(:article, content: "![Alt text](#{pic.image.url})")
      expect(article.used_images).to eq [pic.id]
      expect(article.pictures.first).to eq pic
    end
  end
end
