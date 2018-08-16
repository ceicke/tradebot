class Strategy

  def run

    initialize_assets

    while true
      Asset.active.each_with_index do |asset, index|

        sleep $sleep_time if index > 0

        puts ''
        Logger.log "-= Asset #{asset.id} =-"
        asset_history = asset.record_history
        asset.plot_history
        Logger.log "Win / Loss: #{asset.current_win} EUR"

        # do nothing if we only have one history point
        if asset.asset_histories.length < 10
          Logger.log "-> does not have enough history points yet (currently: #{asset.asset_histories.count})."
          next
        end

        # do nothing if we already lost after the initial long
        if asset_history.rate < asset.rate
          Logger.log "-> only lost so far (initial: #{asset.rate}, current: #{asset_history.rate})."
          next
        end

        # keep if we are on an upward trend or if nothing has happend
        if asset.upward_trend?
         Logger.log "-> is on an upward trend (initial: #{asset.rate}, current: #{asset_history.rate})."
         next
        end

        # sell if we are detecting a downward trend and the asset is shortable
        if asset.downward_trend?
          Logger.log "-> is on a downward trend (initial: #{asset.rate}, current: #{asset_history.rate})."
          if asset.shortable?
            Logger.log '-> Shorting'
            asset.short
            initialize_assets false
          else
            Logger.log '-> Not shortable.'
          end

        end

      end
    end
    sleep $sleep_time
  end

  def initialize_assets(initial = true)
    while Asset.active.size < $asset_amount
      Logger.log "Current asset amount: #{Asset.active.size}."
      a = Asset.new
      a.long
      sleep $sleep_time if initial
    end
  end

end
