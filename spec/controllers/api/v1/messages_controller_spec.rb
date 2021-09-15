require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  fixtures :users, :conversations, :messages

  let(:user) { User.first }

  before do
    request.headers.merge! user.create_new_auth_token
  end

  it 'Create conversation if user never chat' do
    post :create, params: { receiver_id: User.third, message: { content: 'Test send text' } }
    expect(response.status).to eq(200)
    expect(Conversation.count).to eq(3)
  end

  it 'Cannot send message to yourself' do
    post :create, params: { receiver_id: user, message: { content: 'Test send text' } }
    expect(JSON.parse(response.body)['error']).to eq('Cannot send message to yourself')
  end

  it 'Successfully send message' do
    post :create, params: { receiver_id: User.second, message: { content: 'Test send text' } }
    expect(response.status).to eq(200)
    expect(Message.count).to eq(4)
  end
end