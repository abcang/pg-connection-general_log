PG:Connection::GeneralLog
===

[![Build Status](https://travis-ci.org/abcang/pg-connection-general_log.svg?branch=master)](https://travis-ci.org/abcang/pg-connection-general_log)

A monkey patch for pg.
Stock all general logs.

Inspired by [mysql2-client-general_log](https://github.com/ksss/mysql2-client-general_log)

```ruby
#! /usr/bin/env ruby

require "pg/connection/general_log"

PG::Connection::GeneralLog.prepend_module

client = PG::Connection.new(config)
client.query("SELECT * FROM users LIMIT 1")

p PG::Connection::GeneralLog.general_log #=>
# [
#   #<struct PG::Connection::GeneralLog::Log
#     sql="SELECT * FROM users LIMIT 1",
#     args=[],
#     backtrace=["script.rb:6:in `<main>'"],
#     time=0.0909838349907659>
# ]
```

## Examples

### sinatra

config.ru:
```ruby
require_relative './test'

require 'pg/connection/general_log'

use PG::Connection::GeneralLog::Middleware, enabled: true, backtrace: true, path: '/tmp/general_log'
run Sinatra::Application
```

test.rb:
```ruby
require 'sinatra'
require 'pg'

helpers do
  def db
    Thread.current[:db] ||= PG::Connection.new(config)
  end
end

get '/' do
  db.exec("SELECT * FROM users WHERE name = 'hoge'")
  db.exec_params('SELECT * FROM users WHERE name = $1', ['hoge'])

  db.prepare('select', 'SELECT * FROM users WHERE name = $1')
  db.exec_prepared('select', ['bar'])
  db.exec_prepared('select', ['foo'])
end
```

/tmp/general_log/2017-11-19.log:
```
REQUEST GET	/	4
SQL	(0000.89ms)	SELECT * FROM users WHERE name = 'hoge'	[]	/path/to/test.rb:12:in `block in <main>'
SQL	(0000.78ms)	SELECT * FROM users WHERE name = $1	["hoge"]	/path/to/test.rb:13:in `block in <main>'
SQL	(0000.66ms)	SELECT * FROM users WHERE name = $1	["barr"]	/path/to/test.rb:16:in `block in <main>'
SQL	(0000.65ms)	SELECT * FROM users WHERE name = $1	["foo"]	/path/to/test.rb:17:in `block in <main>'
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg-connection-general_log'
```

And then execute:

    $ bundle


## Test

```ruby
$ bundle exec rake
```

## Example server

```ruby
$ bundle exec rake example
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
