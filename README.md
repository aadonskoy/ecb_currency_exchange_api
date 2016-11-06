# ECP Daily Exchange Rates API

Simple api service for convertation USD to EUR for selected date.

## Install and run server
For install it update DailyRates and run server just type in your terminal:

    bundle install
    rake db:create db:migrate
    rake ecb_currency_exchange_api:fetch
    rails server

## For testing
Just type commands in the terminal:

    bundle install
    rspec

## How it work

    curl http://localhost:3000/api/v1/rates/2016-11-06?amount=100

It will response with json data (amount of usd).
