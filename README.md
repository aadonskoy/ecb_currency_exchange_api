# ECB Daily Exchange Rates API

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

* Response with json data (amount of usd) and `200` status code
  in case everything is ok.
* Response with `422` and error message in case date is in incorrect
  format.
* Response with `404` in case date is before 2000-01-01 (it is not
  support dates before 2000 year).
