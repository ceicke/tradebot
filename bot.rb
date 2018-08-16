#!/usr/bin/env ruby

require 'coinbase/wallet'
require 'active_record'
require 'ascii_chart'

require_relative 'asset'
require_relative 'asset_history'
require_relative 'trade'
require_relative 'strategy'
require_relative 'logger'

require 'pry'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'bot.sqlite3.db'
)

$max_eur_amount = 20.0
$asset_amount = 5
$sleep_time = 30.seconds
$minimum_win_eur_amount = 5.0
$trial_mode = true

$client = Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
$account = $client.primary_account

strategy = Strategy.new
strategy.run
