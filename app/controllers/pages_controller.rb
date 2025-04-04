class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :features, :pricing ]

  def home
    if user_signed_in?
      redirect_to portfolio_path
    end
  end

  def elements
  end

  def features
  end

  def pricing
  end
end
