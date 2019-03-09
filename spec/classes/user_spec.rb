# frozen_string_literal: true

require 'rails_helper'
require "refile/file_double"


RSpec.describe User, "モデルに関するテスト", type: :model do
  describe 'アソシエーション' do
    it "bookを複数持っている" do
      is_expected.to have_many(:books)
    end
  end

  describe 'バリデーション' do
    it "nameがないと保存できない" do 
      is_expected.to validate_presence_of(:name)
    end

    it "nameが２文字以下だと保存できない" do
      is_expected.to validate_length_of(:name).is_at_least(2)
    end

    it "introductionがないと保存できない" do 
      is_expected.to validate_length_of(:introduction).is_at_most(50)
    end
  end

  describe '実際に保存してみる' do
    context "保存できる場合" do
      it "画像なし" do
        expect(FactoryBot.create(:user)).to be_valid
      end
      it "画像あり" do
        expect(FactoryBot.create(:user, :create_with_image)).to be_valid
      end
    end
    context "保存できない場合" do
      it "名前がない" do
        expect(FactoryBot.build(:user, :no_name)).to_not be_valid
      end
      it "自己紹介が51文字以上" do
        expect(FactoryBot.build(:user, :introduction_length_exceed_max)).to_not be_valid
      end
    end
  end
end