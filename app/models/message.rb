class Message < ApplicationRecord
  belongs_to :user
  belongs_to :coin

  after_create_commit :broadcast_message

  private
  def broadcast_message
    # Broadcast the message to the "messages" channel
    broadcast_append_to "coin_#{coin.id}_messages",
      target: "messages",
      partial: "messages/message",
      locals: { message: self, user: user }
  end
end
