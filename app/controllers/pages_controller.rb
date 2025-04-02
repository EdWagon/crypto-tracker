class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :features, :pricing ]

  def home
  end

  def elements
  end

  def features
  end

  def pricing
  end
end
