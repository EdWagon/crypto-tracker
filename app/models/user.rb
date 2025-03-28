class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :watchlists
  has_many :wallets
  has_many :wallets_coins, through: :wallets
  has_many :coins, through: :wallets_coins
  has_many :transactions
end
