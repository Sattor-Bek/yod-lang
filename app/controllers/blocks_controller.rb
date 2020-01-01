class BlocksController < ApplicationController

  def index
    @blocks = Block.where(subtitle_id: params[:subtitle_id])

    respond_to do |format|
      format.html
      format.csv { send_data @blocks.as_csv }
    end
  end
end
