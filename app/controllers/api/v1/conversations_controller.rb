class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_api_user!
  
  def index
    conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_api_user, current_api_user)
                                .order(updated_at: :desc)

    render json: { data: conversations, status: :success }
  end

  def show
    receiver_id = User.find(params[:id])
    conversation = Conversation.where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                                      current_api_user, receiver_id, receiver_id, current_api_user).first
    
    if conversation.nil?
      render json: { error: "Invalid conversation", status: :unprocessable_entity }
    else
      messages = conversation.messages.order(updated_at: :desc)
      unread_message = unread_messages(conversation, current_api_user)

      render json: { data: messages, meta: { unread_message: unread_message.size }, status: :success }

      unread_message.update_all(read_at: Time.now)
    end
  end

  private
    def unread_messages(conversation, user)
      conversation.messages.where.not(user_id: current_api_user).where(read_at: nil)
    end
end