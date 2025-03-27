class SearchController < ApplicationController
  def index
    if params[:query].present?
      @results = PgSearch.multisearch(params[:query]).includes(:searchable)
    else
      @results = []
    end

    respond_to do |format|
      format.html # Render the normal search page
      format.json { render json: @results.to_json }
    end
  end
end
