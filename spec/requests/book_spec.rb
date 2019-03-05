# frozen_string_literal: true

require 'rails_helper'

describe 'Books', type: :request do
  let(:user) { create(:user, :create_with_books) }
  describe 'GET /books' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get books_path
      expect(response.status).to eq 200
    end
  end

  describe 'GET /books/:book_id' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get book_path(user.books.first)
      expect(response.status).to eq 200
    end
  end

  describe 'GET /books/:book_id/edit' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get book_path(user.books.first)
      expect(response.status).to eq 200
    end
  end
end
