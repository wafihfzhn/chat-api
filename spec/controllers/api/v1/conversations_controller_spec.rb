require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :controller do
  fixtures :users, :conversations

  let(:user) { User.first }

  before do
    request.headers.merge! user.create_new_auth_token
  end

  it 'List all user conversations' do
    conversations = Conversation.where("sender_id = ? OR receiver_id = ?", user, user).order(updated_at: :desc)
    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['data']).to eq(conversations.as_json)
    expect(JSON.parse(response.body)['error']).to eq(nil)
  end

  it 'List all messages in conversation' do
    get :show, params: { id: User.second }
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['error']).to eq(nil)
  end

  it 'User does not have any conversation to another user' do
    user_id = User.third
    get :show, params: { id: user_id }
    expect(JSON.parse(response.body)['error']).to eq('Invalid conversation')
  end
end