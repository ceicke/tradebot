class Asset < ActiveRecord::Base

  has_many :asset_histories
  has_many :trades

  scope :active, -> { where("active = '1'") }

  def long
    rate = $client.buy_price(currency_pair: 'BTC-EUR').amount
    self.btc_value = $max_eur_amount / rate
    self.rate = rate
    self.active = 1

    begin
      $account.buy(amount: self.btc_value, currency: 'BTC') unless $trial_mode

      if self.save
        Trade.create(asset_id: self.id, trade_type: 'buy', btc_value: self.btc_value, rate: rate)
      end

      Logger.log "Long: #{self.id}, BTC: #{self.btc_value}, Rate: #{rate}"

    rescue Exception => e
      Logger.log "Long failed: #{e}"
    end

  end

  def short
    rate = $client.sell_price(currency_pair: 'BTC-EUR').amount

    self.active = 0

    begin
      $account.sell(amount: self.btc_value, currency: 'BTC') unless $trial_mode

      if self.save
        Trade.create(asset_id: self.id, trade_type: 'sell', btc_value: self.btc_value, rate: rate, win: rate - self.rate)
      end

      Logger.log "Short: #{self.id}, BTC: #{self.btc_value}, Rate: #{rate}, Initial Rate: #{self.rate}, Win: #{rate - self.rate} EUR"

    rescue Exception => e
      Logger.log "Short failed: #{e}"
    end


  end

  def shortable?
    latest_rate = self.asset_histories.order('created_at').last.rate

    return latest_rate - self.rate >= $minimum_win_eur_amount + $max_eur_amount
  end

  def upward_trend?
    asset_histories = self.asset_histories.order('created_at')

    return asset_histories.last.rate >= asset_histories[-2].rate
  end

  def downward_trend?
    asset_histories = []
    max_rate = 0
    reverse_asset_histories = self.asset_histories.order('created_at').reverse

    reverse_asset_histories.each do |asset_history|
      if asset_history.rate >= self.rate
        asset_histories << asset_history
        max_rate = asset_history.rate > max_rate ? asset_history.rate : max_rate
      else
        break
      end
    end

    if asset_histories.empty?
      return false
    end


    return ((asset_histories.first.rate - self.rate) / (max_rate - self.rate)) <= 0.8
  end

  def record_history
    AssetHistory.create(asset_id: self.id, rate: $client.sell_price(currency_pair: 'BTC-EUR').amount)
  end
end
