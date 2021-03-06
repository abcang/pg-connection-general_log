require 'sinatra'
require 'pg'

helpers do
  def db
    Thread.current[:db] ||= PG.connect(
      host: '127.0.0.1',
      user: 'postgres',
      dbname: 'pg_connection_general_log_test'
    )
  end

  def pg
    PG.connect(
      host: '127.0.0.1',
      user: 'postgres'
    )
  end

  def init
    db.exec('DROP TABLE IF EXISTS users')
    db.exec(<<-SQL)
    CREATE TABLE users (
      id SERIAL NOT NULL PRIMARY KEY,
      name varchar(255) NOT NULL UNIQUE,
      password varchar(255) NOT NULL
    );
    SQL
    db.exec(<<-SQL)
    INSERT INTO users (name, password)
    VALUES ('hoge', 'cheap-pass'),
    ('foo', 'fooo'),
    ('bar', 'barr')
    ;
    SQL
  end
end

get '/' do
  db.exec("SELECT * FROM users WHERE name = 'hoge'")
  db.exec_params('SELECT * FROM users WHERE name = $1', ['hoge'])

  db.prepare('select', 'SELECT * FROM users WHERE name = $1')
  db.exec_prepared('select', ['bar'])
  db.exec_prepared('select', ['foo'])

  'ok'
end

get '/init' do
  pg.exec('DROP DATABASE IF EXISTS pg_connection_general_log_test')
  pg.exec('CREATE DATABASE pg_connection_general_log_test')

  init

  'init'
end

get '/down' do
  pg.exec('DROP DATABASE IF EXISTS pg_connection_general_log_test')

  'down'
end
