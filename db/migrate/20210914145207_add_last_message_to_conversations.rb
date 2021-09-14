class AddLastMessageToConversations < ActiveRecord::Migration[6.1]
  def change
    add_column :conversations, :last_message, :text
  end
end
