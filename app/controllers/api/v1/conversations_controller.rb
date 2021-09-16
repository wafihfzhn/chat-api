class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_api_user!
  
  def index
    conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_api_user, current_api_user)
                                .order(updated_at: :desc)
    conversations_data = []
    conversations.each do |conversation|
      last_message = { "last_message" => conversation.messages.last.content }
      unread_messages_count = { "unread_messages_count" => unread_messages(conversation, current_api_user).size }
      conversation = JSON::parse(conversation.to_json).merge(last_message, unread_messages_count)
      conversations_data << conversation
    end

    render json: { data: conversations_data, status: :success }
  end

  def show
    receiver_id = User.find(params[:id])
    conversation = Conversation.where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                                      current_api_user, receiver_id, receiver_id, current_api_user).first
    
    if conversation.nil?
      render json: { error: "Invalid conversation", status: :unprocessable_entity }
    else
      messages = conversation.messages.order(created_at: :desc)
      unread_messages = unread_messages(conversation, current_api_user)

      render json: { data: messages, status: :success }

      unread_messages.update_all(read_at: Time.now)
    end
  end

  private
    def unread_messages(conversation, user)
      conversation.messages.where.not(user_id: current_api_user).where(read_at: nil)
    end
end