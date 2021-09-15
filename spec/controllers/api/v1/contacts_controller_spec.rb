require 'rails_helper'

RSpec.describe Api::V1::ContactsController, type: :controller do
  fixtures :users

  let(:user) { User.first }

  before do
    request.headers.merge! user.create_new_auth_token
  end

  it 'List contacts without current user' do
    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['data']).to eq(User.where.not(id: user).as_json)
  end
end