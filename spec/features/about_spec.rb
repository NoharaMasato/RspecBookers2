require 'rails_helper'
# config.active_support.deprecation = :silenceをconfigのtest.rbに付け加える必要がある
RSpec.feature "Homeページ、サインアップ、ログイン、ログアウトに関するテスト", type: :feature do
  before do
    @user = FactoryBot.create(:user, :create_with_books)
  end

  feature "サインアップ" do
    before do
      visit new_user_registration_path
      find_field('user[name]').set("name_a")
      find_field('user[email]').set("aa@aa")
      find_field('user[password]').set("pppppp")
      find_field('user[password_confirmation]').set("pppppp")
    end
    scenario "正しくサインアップできているか" do
      expect {
        find("input[name='commit']").click
      }.to change(User, :count).by(1)
    end
    scenario "リダイレクト先は正しいか" do
      find("input[name='commit']").click
      expect(current_path).to match(Regexp.new("/users/[0-9]+$")) #何番のuserとして保存するかわからないため、正規表現を使用
      expect(page).to have_content "name_a"
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      find("input[name='commit']").click
      expect(page).to have_content "successfully"
    end
  end

  feature "ログイン" do
    before do
      visit new_user_session_path
      # fill_in "user[name]",with: @user.name
      find_field('user[name]').set(@user.name)
      find_field('user[password]').set(@user.password)
      find("input[name='commit']").click
    end
    scenario "正しくログインして、リダイレクトされているか" do #正しくログインできていることと、リダイレクト先が合っていることを別々に調べたい
      expect(page).to have_current_path user_path(@user)
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      expect(page).to have_content "successfully"
    end
  end

  feature "ログアウト" do
    before do
      login(@user)
      visit user_path(@user)
      click_on "logout"
    end
    scenario "正しくログアウトして、リダイレクトされているか" do
      expect(page).to have_current_path "/"
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      expect(page).to have_content "successfully"
    end
  end

  feature "ヘッダーのリンク" do
    scenario "ログイン時" do
      login(@user)
      visit root_path
      expect(page).to have_link "",href: user_path(@user)
      expect(page).to have_link "",href: users_path
      expect(page).to have_link "",href: books_path
      expect(page).to have_link "",href: destroy_user_session_path
    end
    scenario "ログアウト時" do
      visit root_path
      expect(page).to have_link "",href: root_path
      expect(page).to have_link "",href: "/home/about" #実際このルートじゃなくてもいい気がする
      expect(page).to have_link "",href: new_user_session_path
      expect(page).to have_link "",href: new_user_registration_path
    end
  end
end