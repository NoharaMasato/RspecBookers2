class BooksController < ApplicationController
	before_action :authenticate_user!
	#ビフォーアクションはこのコントローラーが実行される前という意味
	#authenticate userはdeviseで用意されているメソッドで、ログイン認証がされていないとrootパスにリダイレクトされる。
	#アプリケーションコントローラーに記述すれば全適用されるが、今回はhomeコントローラーは適用したくないので、booksとusersに適用

  def show
  	@book = Book.find(params[:id])
  end

  def index
  	@book = Book.new #new bookの新規投稿で必要、ブックモデルに新しいデータを渡すのでnew
  	@books = Book.all #一覧表示するためにBookモデルの情報を全てくださいのall
  end

  def create
  	@book = Book.new(book_params) #Bookモデルのテーブルを使用しているのでbookコントローラで保存する。
  	@book.user_id = current_user.id #カレント（ログインしてる人）idをbook user id変数として格納する。
  	if @book.save #入力されたデータをdbに保存する。
  		redirect_to @book, notice: "successfully created book!"#保存された場合の移動先を指定。
  	else
  		@books = Book.all
  		render 'index'
  	end
  end

  def edit
  	@book = Book.find(params[:id])
  	if @book.user.id != current_user.id
  		redirect_to books_path
  	end
  end



  def update
  	@book = Book.find(params[:id])
  	if @book.update(book_params)
  		redirect_to @book, notice: "successfully updated book!"
  	else #if文でエラー発生時と正常時のリンク先を枝分かれにしている。
  		render "edit"
  	end
  end

  def destroy
  	@book = Book.find(params[:id])
  	@book.destroy
  	redirect_to books_path, notice: "successfully delete book!"
  end

  private

  def book_params
  	params.require(:book).permit(:title, :body)
  end

end
