require 'rails_helper'

RSpec.feature "Userに関するテスト", type: :feature do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    create_list(:book, 3, user_id: @user1.id)
    create_list(:book, 3, user_id: @user2.id)
  end
  feature "ログインしていない状態で" do
    feature "リダイレクトの確認" do
      scenario "userの一覧ページ" do
        visit users_path
        expect(page).to have_current_path "/users/sign_in"
      end

      scenario "userの詳細ページ" do
        visit user_path(@user1)
        expect(page).to have_current_path "/users/sign_in"
      end

      scenario "userの編集ページ" do
        visit edit_user_path(@user1)
        expect(page).to have_current_path "/users/sign_in"
      end
    end
  end

  feature "ログインした状態で" do
    before do
      login(@user1)
    end
    # 表示内容とリンクを分けたほうがいいかも
    feature "表示内容とリンクの確認" do
      scenario "userの一覧ページの表示内容とリンク" do
        visit users_path
        expect(page).to have_link "",href: "/users/#{@user1.id}"
        expect(page).to have_content @user1.name
        expect(page).to have_content @user1.introduction
        expect(page).to have_link "",href: "/users/#{@user2.id}"
        expect(page).to have_content @user2.name
      end

      scenario "自分の詳細ページへの表示内容とリンク" do
        visit user_path(@user1)
        expect(page).to have_content @user1.name
        expect(page).to have_content @user1.introduction
        expect(page).to have_link "",href: "/users/#{@user1.id}/edit"

        @user1.books.each do |book|
          expect(page).to have_link book.title,href: "/books/#{book.id}"
          expect(page).to have_content book.body
        end
      end

      scenario "他人の詳細ページへの表示内容とリンク" do
        visit user_path(@user2)
        expect(page).to have_content @user2.name
        expect(page).to have_content @user2.introduction

        @user2.books.each do |book|
          expect(page).to have_link book.title,href: "/books/#{book.id}"
          expect(page).to have_content book.body
        end
      end
    end

    feature "自分のプロフィールの更新" do
      before do
        visit edit_user_path(@user1)
        name_field = all("input")[0]
        introduction_field = all("textarea")[0]
        name_field.set("updated_name")
        introduction_field.set("updated_inttroduction")
      end
      scenario "userが更新されているか" do #他人の本を更新できるかどうかはrequest specでテストしている
        all("input")[-1].click
        expect(page).to have_content "updated_name"
        expect(page).to have_content "updated_inttroduction"
      end
      scenario "リダイレクト先は正しいか" do
        all("input")[-1].click
        expect(page).to have_current_path "/users/#{@user1.id}"
      end
      scenario "サクセスメッセージが表示されているか" do
        all("input")[-1].click
        expect(page).to have_content "successfully"
      end
      scenario "画像が投稿できるか" do
        # expect(page).to have_content "successfully"
      end
    end

    feature "他人のプロフィールの更新" do
      scenario "ページに行けず、マイページにリダイレクトされるか" do
        visit edit_user_path(@user2)
        expect(page).to have_current_path user_path(@user1)
      end
    end

    feature "有効ではないuserの更新" do
      before do
        visit edit_user_path(@user1)
        name_field = all("input")[0]
        name_field.set(nil)
      end
      scenario "リダイレクト先が正しいか" do
        all("input")[-1].click
        expect(page).to have_current_path "/users/#{@user1.id}"
      end
      scenario "エラーメッセージが出るか" do
        all("input")[-1].click
        expect(page).to have_content "Name can't be blank"
      end
    end
  end
end
