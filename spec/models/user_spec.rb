# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, "model", type: :model do
  describe 'アソシエーション' do
    it "bookを複数持っている" do
      is_expected.to have_many(:books).dependent(:destroy) #dependentがいるか微妙
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
    it "保存できる場合" do
      expect(FactoryBot.create(:user)).to be_valid
    end
  end
end
