# Tradebot
A very simple BTC-EUR trading bot for Coinbase written in Ruby.

# Setup
You will need API access to Coinbase and setup two environment variables that hold your credentials:

* `COINBASE_API_KEY` the API key
* `COINBASE_API_SECRET` the API key's secret

Next you will need to create the SQLite database. While inside the base directory of the bot, execute the following command:

```
sqlite3 bot.sqlite3.db
```

When inside the SQLite shell, execute the following command to create the schema from the migration file:

```
.read support/sqlite_migration.sql
```

Next step is to install the rubygems:

```
bundle install
```

Have a look at the variables in `bot.rb`

* `$max_eur_amount`: this is the EUR amount which the bot is going to buy
* `$asset_amount`: how many assets does the bot work with
* `$sleep_time`: this is the time that the bot sleeps between operations (note that it does not make sense with the current bot's strategy and considering the Coinbase API to do this really fast)
* `$minimum_win_eur_amount`: the minimum amount that you want to make when selling an asset. If it is below this number, then the bot does not sell the asset (consider the trading fee that Coinbase charges)
* `$trial_mode`: set this to `false` if you want to do real trades and spend actual money. If this is set to `true`, then the bot will not execute the longs or shorts but only pretends it does

Run it:

```
./bot.rb
```

# Configuring output
If you don't do anything, the bot will print everything to the command line and log to Syslog. You can tweak this in `logger.rb`. 

# How it works / strategy
The bot does `$asset_amount` initial buys. One immediately when starting and the next one after `$sleep_time`. Afterwards the bot will watch the market and record the history for `10 * $asset_amount * $sleep_time`. After this setup phase is over, it will try to find out if the market is going up or down. If it is going down, then the bot does nothing but will hold on to the asset. So you could say that the bot bets on rising rates. The bot does nothing with the assets when the rates are rising. When the rates are falling, it sells the asset when we have reached 80% of the peak rate, but only if `$minimum_win_eur_amount` has been reached.
