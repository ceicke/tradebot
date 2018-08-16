class Strategy

  def run

    initialize_assets

    while true
      Asset.all.each_with_index do |asset, index|

        sleep $sleep_time if index > 0
        asset_history = asset.record_history

        # do nothing if we only have one history point
        if asset.asset_histories.length < 10
          Logger.log "Asset #{asset.id} does not have enough history points yet (currently: #{asset.asset_histories.count})."
          next
        end

        # do nothing if we already lost after the initial long
        if asset_history.rate < asset.rate
          Logger.log "Asset #{asset.id} only lost so far (initial: #{asset.rate}, current: #{asset_history.rate})."
          next
        end

        # keep if we are on an upward trend or if nothing has happend
        if asset.upward_trend?
         Logger.log "Asset #{asset.id} is on an upward trend (initial: #{asset.rate}, current: #{asset_history.rate})."
         next
        end

        # sell if we are detecting a downward trend and the asset is shortable
        if asset.downward_trend?
          Logger.log "Asset #{asset.id} is on a downward trend (initial: #{asset.rate}, current: #{asset_history.rate}). Shorting."
          asset.short if asset.shortable?
          initialize_assets false
        end

      end
    end
    sleep $sleep_time
  end

  def initialize_assets(initial = true)
    while Asset.active.size < $asset_amount
      Logger.log "Current asset amount: #{Asset.all.size}."
      a = Asset.new
      a.long
      sleep $sleep_time if initial
    end
  end

end
