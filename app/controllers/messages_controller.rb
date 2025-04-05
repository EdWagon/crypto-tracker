class MessagesController < ApplicationController

  def create
    @coin = Coin.find(params[:coin_id])
    @message = Message.new(message_params)
    @message.user = current_user
    @message.coin = @coin
    authorize @message

    if @message.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:messages, partial: "messages/message",
              target: "messages",
              locals: { message: @message, user: current_user })
        end
        format.html { redirect_to coin_path(@coin) }
      end
    else
      flash[:alert] = "Message not created"
      render "coins/show", status: :unprocessable_entity
    end
  end

  private
  def message_params
    params.require(:message).permit(:content)
  end

end
