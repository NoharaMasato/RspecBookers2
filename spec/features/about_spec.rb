require 'rails_helper'
# config.active_support.deprecation = :silenceをconfigのtest.rbに付け加える必要がある
RSpec.feature "Homeページ、サインアップ、ログイン、ログアウトに関するテスト", type: :feature do
  before do
    @user = FactoryBot.create(:user)
    create_list(:book, 3, user_id: @user.id)
  end

  feature "サインアップ" do
    before do
      visit new_user_registration_path
      fill_in 'user_name', with: 'name_a'
      fill_in 'user_email', with: 'aa@aa'
      fill_in 'user_password', with: 'pppppp'
      fill_in 'user_password_confirmation', with: 'pppppp'
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
      fill_in 'user_name', with: @user.name
      fill_in 'user_password', with: @user.password
    end
    scenario "正しくログインして、リダイレクトされているか" do #正しくログインできていることと、リダイレクト先が合っていることを別々に調べたい
      find("input[name='commit']").click
      expect(page).to have_current_path user_path(@user)
    end
    scenario "サクセスメッセージは正しく表示されるか" do
      find("input[name='commit']").click
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