require 'rails_helper'
# config.active_support.deprecation = :silenceをconfigのtest.rbに付け加える必要がある
RSpec.feature "Homeページ、サインアップ、ログイン、ログアウトに関するテスト", type: :feature do
  before do
    @user = FactoryBot.create(:user)
    create_list(:book, 3, user_id: @user.id)
  end

  feature "サインアップ" do
    before do
      visit "users/sign_up"
      all("input")[0].set("name_a")
      all("input")[1].set("aa@aa")
      all("input")[2].set("pppppp")
      all("input")[3].set("pppppp")
    end
    scenario "正しくサインアップできているか" do
      expect {
        all("input")[-1].click
      }.to change(User, :count).by(1)
    end
    scenario "リダイレクト先は正しいか" do
      all("input")[-1].click
      expect(current_path).to match(Regexp.new("/users/[0-9]+$")) #何番のブックとして保存するかわからないため、正規表現を使用
      expect(page).to have_content "name_a"
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      all("input")[-1].click
      expect(page).to have_content "successfully"
    end
  end
  feature "ログイン" do
    before do
      visit "users/sign_in"
      all("input")[0].set(@user.name)
      all("input")[1].set(@user.password)
    end
    scenario "正しくログインして、リダイレクトされているか" do #正しくログインできていることと、リダイレクト先が合っていることを別々に調べたい
      all("input")[-1].click
      expect(page).to have_current_path "/users/#{@user.id}"
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      all("input")[-1].click
      expect(page).to have_content "successfully"
    end
  end

  feature "ログアウト" do
    before do
      login(@user)
      visit user_path(@user)
    end
    scenario "正しくログアウトして、リダイレクトされているか" do
      click_on "logout"
      expect(page).to have_current_path "/"
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      click_on "logout"
      expect(page).to have_content "successfully"
    end
  end

  feature "ヘッダーのリンク" do
    scenario "ログイン時" do
      login(@user)
      visit root_path
      expect(page).to have_link "",href: "/users/#{@user.id}"
      expect(page).to have_link "",href: "/users"
      expect(page).to have_link "",href: "/books"
      expect(page).to have_link "",href: "/users/sign_out"
    end
    scenario "ログアウト時" do
      visit root_path
      expect(page).to have_link "",href: "/"
      expect(page).to have_link "",href: "/home/about" #実際このルートじゃなくてもいい気がする
      expect(page).to have_link "",href: "/users/sign_in"
      expect(page).to have_link "",href: "/users/sign_up"
    end
  end
end