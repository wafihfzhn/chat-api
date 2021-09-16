require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :controller do
  fixtures :users, :conversations, :messages

  let(:user) { User.first }

  before do
    request.headers.merge! user.create_new_auth_token
  end

  it 'List all user conversations' do
    conversations = Conversation.where("sender_id = ? OR receiver_id = ?", user, user).order(updated_at: :desc)
    conversations_data = []
    conversations.each do |conversation|
      last_message = { "last_message" => conversation.messages.last.content }
      unread_messages_count = { "unread_messages_count" => conversation.messages.where.not(user_id: user).where(read_at: nil).size }
      conversation = JSON::parse(conversation.to_json).merge(last_message, unread_messages_count)
      conversations_data << conversation
    end
    get :index
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)['data']).to eq(conversations_data.as_json)
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