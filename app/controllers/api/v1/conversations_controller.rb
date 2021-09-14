class Api::V1::ConversationsController < ApplicationController
  before_action :authenticate_api_user!
  
  def index
    conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_api_user, current_api_user)
                                .order(updated_at: :desc)

    render json: { data: conversations, status: :success }
  end

  def show
    user = User.find(params[:id])
    conversation = Conversation.where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                                      current_api_user, user, user, current_api_user).first
    
    if conversation.nil?
      render json: { error: "Invalid conversation", status: :unprocessable_entity }
    else
      messages = Message.where(conversation_id: conversation)

      render json: { data: messages, status: :success }
    end
  end
end