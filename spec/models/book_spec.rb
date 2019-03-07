# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Book, "model", type: :model do
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
    it "保存できる場合" do
      user = FactoryBot.create(:user)
      expect(FactoryBot.create(:book, user_id: user.id)).to be_valid
    end
  end
end
