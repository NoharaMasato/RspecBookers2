require 'rails_helper'

RSpec.feature "Bookに関するテスト", type: :feature do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    create_list(:book, 3, user_id: @user1.id)
    create_list(:book, 3, user_id: @user2.id)
  end
  feature "ログインしていない状態で" do
    feature "リダイレクトの確認" do
      scenario "bookの一覧ページ" do
        visit books_path
        expect(page).to have_current_path new_user_session_path
      end

      scenario "bookの詳細ページ" do
        visit book_path(@user1.books.first)
        expect(page).to have_current_path new_user_session_path
      end

      scenario "bookの編集ページ" do
        visit edit_book_path(@user1.books.first)
        expect(page).to have_current_path new_user_session_path
      end
    end
  end

  feature "ログインした状態で" do
    before do
      login(@user1)
    end
    # 表示内容とリンクを分けたほうがいいかも
    feature "表示内容とリンクの確認" do
      scenario "bookの一覧ページの表示内容とリンク" do
        visit books_path
        books = @user1.books + @user2.books
        books.each do |book|
          expect(page).to have_link book.title,href: book_path(book)
          expect(page).to have_content book.body
        end
        expect(page).to have_link "",href: edit_user_path(@user1)
        expect(page).to have_content @user1.name
        expect(page).to have_content @user1.introduction
      end

      scenario "bookの一覧ページでテーブルタグを使用しているか" do
        visit books_path
        expect(page).to have_selector "table"
      end

      scenario "自分のbookの詳細ページへの表示内容とリンク" do
        book = @user1.books.first
        visit book_path(book)
        expect(page).to have_content book.title
        expect(page).to have_content book.body
        expect(page).to have_link "",href: edit_book_path(book)
        expect(page).to have_link @user1.name,href: user_path(@user1)

        expect(page).to have_link "",href: edit_user_path(@user1)
        expect(page).to have_content @user1.name
        expect(page).to have_content @user1.introduction
      end

      scenario "他人のbookの詳細ページへの表示内容とリンク" do
        book = @user2.books.first
        visit book_path(book)
        expect(page).to have_content book.title
        expect(page).to have_content book.body
        expect(page).to_not have_link "",href: edit_book_path(book)
        expect(page).to have_link @user2.name,href: user_path(@user2)

        # expect(page).to_not have_link "",href: "/users/#{@user2.id}/edit" 他人の詳細ページでボタンは存在してしまう
        expect(page).to have_content @user2.name
        expect(page).to have_content @user2.introduction
      end
    end

    feature "マイページからbookを投稿" do
      before do
        visit user_path(@user1)
        fill_in 'book_title', with: 'title_a'
        fill_in 'book_body', with: 'body_b'
      end
      scenario "正しく保存できているか" do
        expect {
          find("input[name='commit']").click
        }.to change(@user1.books, :count).by(1)
      end
      scenario "リダイレクト先は正しいか" do
        find("input[name='commit']").click
        expect(current_path).to match(Regexp.new("/books/[0-9]+$")) #何番のブックとして保存するかわからないため、正規表現を使用
        expect(page).to have_content "title_a"
        expect(page).to have_content "body_b"
      end
      scenario "サクセスメッセージは正しく表示されるか" do
        find("input[name='commit']").click
        expect(page).to have_content "successfully"
      end
    end

    feature "book一覧ページからbookを投稿" do
      before do
        visit books_path
        fill_in 'book_title', with: 'title_c'
        fill_in 'book_body', with: 'body_d'
      end
      scenario "正しく保存できているか" do
        expect {
          find("input[name='commit']").click
        }.to change(@user1.books, :count).by(1)
      end
    end

    feature "有効ではない内容のbookを投稿" do
      before do
        visit user_path(@user1)
        fill_in 'book_title', with: 'title_e'
      end
      scenario "保存されないか" do
        expect {
          find("input[name='commit']").click
        }.to change(@user1.books, :count).by(0)
      end
      scenario "リダイレクト先は正しいか" do
        find("input[name='commit']").click
        expect(page).to have_current_path books_path
      end
      scenario "エラーメッセージは正しく表示されるか" do
        find("input[name='commit']").click
        expect(page).to have_content "Body can't be blank"
      end
    end

    feature "自分のbookの更新" do
      before do
        book = @user1.books.first
        visit edit_book_path(book)
        fill_in 'book_title', with: 'update_title_a'
        fill_in 'book_body', with: 'update_body_b'
        find("input[name='commit']").click
      end
      scenario "本が更新されているか" do #他人の本を更新できるかどうかはrequest specでテストしている
        expect(page).to have_content "update_title_a"
        expect(page).to have_content "update_body_b"
      end
      scenario "リダイレクト先は正しいか" do
        expect(page).to have_current_path book_path(@user1.books.first)
      end
      scenario "サクセスメッセージが表示されているか" do
        expect(page).to have_content "successfully"
      end
    end

    feature "他人のbookの更新" do
      scenario "ページに行けず、book一覧ページにリダイレクトされるか" do
        visit edit_book_path(@user2.books.first)
        expect(page).to have_current_path books_path
      end
    end

    feature "有効ではないbookの更新" do
      before do
        book = @user1.books.first
        visit edit_book_path(book)
        fill_in 'book_title', with: nil
        find("input[name='commit']").click
      end
      scenario "リダイレクト先は正しいか" do
        expect(page).to have_current_path book_path(@user1.books.first)
      end
      scenario "エラーが出るか" do
        expect(page).to have_content "Title can't be blank"
      end
    end

    feature "bookの削除" do
      before do
        book = @user1.books.first
        visit book_path(book)
      end
      scenario "bookが削除されているか" do
        expect {
          all("a[data-method='delete']")[-1].click #データメソッドがdeleteのaタグはログアウトと削除ボタンの２つある
        }.to change(@user1.books, :count).by(-1)
      end
      scenario "リダイレクト先が正しいか" do
        all("a[data-method='delete']")[-1].click #データメソッドがdeleteのaタグはログアウトと削除ボタンの２つある
        expect(page).to have_current_path books_path
      end
    end
  end
end
