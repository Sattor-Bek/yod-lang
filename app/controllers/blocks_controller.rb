class BlocksController < ApplicationController
  before_action :set_block, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.csv { render text: @blocks.to_csv }
    end
  end

  def set_block
    @blocks = Block.where(subtitle_id: params[:subtitle_id])
  end
end
