# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, "モデルに関するテスト", type: :model do
  describe 'アソシエーション' do
    it "userに属している" do
      is_expected.to belong_to(:user)
    end
  end

  describe 'バリデーション' do
    it "titleがないと保存できない" do 
      is_expected.to validate_presence_of(:title)
    end

    it "bodyがないと保存できない" do
      is_expected.to validate_presence_of(:body)
    end

    it "bodyが200文字以上だと保存できない" do
      is_expected.to validate_length_of(:body).is_at_most(200)
    end
  end

  describe '実際に保存してみる' do
    context "保存できる場合" do
      it "userと共に保存" do
        user = FactoryBot.create(:user)
        expect(FactoryBot.create(:book, user_id: user.id)).to be_valid
      end
    end
    context "保存できない場合" do
      it "userと結びつけず保存" do
        expect(FactoryBot.build(:book)).to_not be_valid
      end
      it "titleがない" do
        expect(FactoryBot.build(:book, :no_title)).to_not be_valid
      end
      it "bodyがない" do
        expect(FactoryBot.build(:book, :no_body)).to_not be_valid
      end
      it "bodyが201文字以上だと保存できない" do
        expect(FactoryBot.build(:book, :body_length_exceed_max)).to_not be_valid
      end
    end
  end
end