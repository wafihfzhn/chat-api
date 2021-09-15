class RemoveLastMessageFromConversations < ActiveRecord::Migration[6.1]
  def change
    remove_column :conversations, :last_message
  end
end
