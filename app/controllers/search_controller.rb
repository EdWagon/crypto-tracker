class SearchController < ApplicationController
  def index
    # Check if there is a search query
    if params[:query].present?
      # Perform the multisearch using PgSearch
      search_results = PgSearch.multisearch(params[:query]).includes(:searchable)
      # .includes(:searchable) is used to eager load associated records to avoid making more database queries than we need to
      # Without .includes(:searchable), when we iterate over search_results, say there are 100 search_results, we'd make 101 queries (1 for the multisearch and 100 for each result.searchable)
      # With .includes(:searchable), we makes just 2 queries: 1 to fetch the search results from the multisearch, and 1 to fetch all the associated searchable records

      # Initialize empty arrays to store the IDs of Wallets and Coins
      wallet_ids = []
      coin_ids = []

      # Loop through the search results to find Wallets and Coins
      search_results.each do |result|
        # If the result is a Wallet, add its ID to the wallet_ids array
        if result.searchable_type == "Wallet"
          wallet_ids << result.searchable_id
        # If the result is a Coin, add its ID to the coin_ids array
        elsif result.searchable_type == "Coin"
          coin_ids << result.searchable_id
        end
      end

      # Apply policy scope for Wallet and Coin to ensure we load only records the user is allowed to see, and then filter them by the found IDs
      wallets = policy_scope(Wallet).where(id: wallet_ids)
      coins = Coin.where(id: coin_ids)

      @results = {
        wallets: wallets,
        coins: coins
      }
    else
      # If there is no search query, return empty arrays for Wallets and Coins
      @results = {
        wallets: [],
        coins: []
      }
    end

    respond_to do |format|
      format.json { render json: @results.to_json }
    end
  end

  def coins
    query = params[:query]
    @coins = Coin.where("name ILIKE ? OR symbol ILIKE ?", "%#{query}%", "%#{query}%").limit(10)

    render json: @coins.to_json
  end
end
