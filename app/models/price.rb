class Price < ApplicationRecord
  belongs_to :coin


  # def latest
  #   self.class.where(coin_id: coin_id).order(date: :desc).first
  # end
end
