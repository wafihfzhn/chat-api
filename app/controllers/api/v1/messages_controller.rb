class Api::V1::MessagesController < ApplicationController
  before_action :authenticate_api_user!

  def create
    receiver_id = User.find(message_params[:receiver_id])&.id

    if current_api_user.id == receiver_id
      render json: { error: "Cannot send message to yourself" }
    else
      conversation = Conversation.where("(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
                                        current_api_user, receiver_id,
                                        receiver_id, current_api_user
                                       ).first

      if conversation.nil?
        conversation = Conversation.create!(sender_id: current_api_user.id, receiver_id: receiver_id)
      end

      message = Message.new(user: current_api_user,
                            conversation_id: conversation.id,
                            content: message_params[:content])

      if message.save
        conversation.update!(updated_at: message.created_at)

        render json: { data: message, status: :success }
      else
        render json: { error: message.errors.messages, status: :unprocessable_entity }
      end
    end
  end

  private
    def message_params
      params.permit(:content, :receiver_id)
    end
end