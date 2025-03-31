class Watchlist < ApplicationRecord
  belongs_to :user
  has_many :watchlists_coins, dependent: :destroy
  has_many :coins, through: :watchlists_coins

  validates :name, presence: true
end
