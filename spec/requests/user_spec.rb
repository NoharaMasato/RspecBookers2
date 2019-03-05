# frozen_string_literal: true

require 'rails_helper'

describe 'Users', type: :request do
  let(:user) { create(:user) }

  describe 'GET /users' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get users_path
      expect(response.status).to eq 200
    end
  end

  describe 'GET /users/:user_id' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get user_path(user)
      expect(response.status).to eq 200
    end
  end

  describe 'GET /users/:user_id/edit' do
    before do
      login(user)
    end
    it 'request succeeds' do
      get user_path(user)
      expect(response.status).to eq 200
    end
  end
end
