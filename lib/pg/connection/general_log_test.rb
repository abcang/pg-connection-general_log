require 'pg/connection/general_log'

module PGConnectionGeneralLogTest
  def test_main(m)
    PG::Connection::GeneralLog.prepend_module
    client = PG.connect(
      host: '127.0.0.1',
      user: 'postgres'
    )
    client.exec('DROP DATABASE IF EXISTS pg_connection_general_log_test')
    client.exec('CREATE DATABASE pg_connection_general_log_test')

    @client = PG.connect(
      host: '127.0.0.1',
      user: 'postgres',
      dbname: 'pg_connection_general_log_test'
    )
    PG::Connection::GeneralLog.general_log.clear
    exit m.run

    client.exec('DROP DATABASE IF EXISTS pg_connection_general_log_test')
  end

  def db_init
    @client.exec('DROP TABLE IF EXISTS users')
    @client.exec(<<~SQL)
      CREATE TABLE users (
        id SERIAL NOT NULL PRIMARY KEY,
        name varchar(255) NOT NULL UNIQUE,
        password varchar(255) NOT NULL
      );
    SQL
    @client.exec(<<~SQL)
      INSERT INTO users (name, password)
             VALUES ('hoge', 'cheap-pass'),
                    ('foo', 'fooo'),
                    ('bar', 'barr')
      ;
    SQL
    PG::Connection::GeneralLog.general_log.clear
  end

  def test_init(t)
    unless PG::Connection::GeneralLog.general_log.is_a?(Array)
      t.error("initial value expect Array class got #{PG::Connection::GeneralLog.general_log.class}")
    end
    unless PG::Connection::GeneralLog.general_log.empty?
      t.error("initial value expect [] got #{PG::Connection::GeneralLog.general_log}")
    end
  end

  def test_values(t)
    db_init
    ret = @client.exec("SELECT * FROM users WHERE name = '#{'hoge'}'").first
    @client.exec("SELECT * FROM users WHERE name = '#{'bar'}'")
    @client.exec("SELECT * FROM users WHERE name = '#{'foo'}'")

    if PG::Connection::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{PG::Connection::GeneralLog.general_log.length}")
    end
    if PG::Connection::GeneralLog.general_log.any?{|log| !log.is_a?(PG::Connection::GeneralLog::Log)}
      t.error("expect all collection item is instance of PG::Connection::GeneralLog::Log got #{PG::Connection::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => '1', 'name' => 'hoge', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect exec output not change from #{expect} got #{ret}")
    end
    unless PG::Connection::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'hoge'\t\[\]$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format}`")
    end
    unless PG::Connection::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'hoge'\t\[\].+in `test_values'$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_params_values(t)
    db_init
    ret = @client.exec_params('SELECT * FROM users WHERE name = $1', ['hoge']).first
    @client.exec_params('SELECT * FROM users WHERE name = $1', ['bar'])
    @client.exec_params('SELECT * FROM users WHERE name = $1', ['foo'])

    if PG::Connection::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{PG::Connection::GeneralLog.general_log.length}")
    end
    if PG::Connection::GeneralLog.general_log.any?{|log| !log.is_a?(PG::Connection::GeneralLog::Log)}
      t.error("expect all collection item is instance of PG::Connection::GeneralLog::Log got #{PG::Connection::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => '1', 'name' => 'hoge', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect exec output not change from #{expect} got #{ret}")
    end
    unless PG::Connection::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \$1\t\["hoge"\]$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format}`")
    end
    unless PG::Connection::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \$1\t\["hoge"\].+in `test_params_values'$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_prepare_values(t)
    db_init
    @client.prepare('select', 'SELECT * FROM users WHERE name = $1')
    ret = @client.exec_prepared('select', ['hoge']).first
    @client.exec_prepared('select', ['bar'])
    @client.exec_prepared('select', ['foo'])

    if PG::Connection::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{PG::Connection::GeneralLog.general_log.length}")
    end
    if PG::Connection::GeneralLog.general_log.any?{|log| !log.is_a?(PG::Connection::GeneralLog::Log)}
      t.error("expect all collection item is instance of PG::Connection::GeneralLog::Log got #{PG::Connection::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => '1', 'name' => 'hoge', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect exec output not change from #{expect} got #{ret}")
    end
    unless PG::Connection::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \$1\t\["hoge"\]$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format}`")
    end
    unless PG::Connection::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = \$1\t\["hoge"\].+in `test_prepare_values'$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_async_values(t)
    db_init
    ret = @client.async_exec("SELECT * FROM users WHERE name = '#{'hoge'}'").first
    @client.async_exec("SELECT * FROM users WHERE name = '#{'bar'}'")
    @client.async_exec("SELECT * FROM users WHERE name = '#{'foo'}'")

    if PG::Connection::GeneralLog.general_log.length != 3
      t.error("expect log length 3 got #{PG::Connection::GeneralLog.general_log.length}")
    end
    if PG::Connection::GeneralLog.general_log.any?{|log| !log.is_a?(PG::Connection::GeneralLog::Log)}
      t.error("expect all collection item is instance of PG::Connection::GeneralLog::Log got #{PG::Connection::GeneralLog.general_log.map(&:class).uniq}")
    end
    expect = { 'id' => '1', 'name' => 'hoge', 'password' => 'cheap-pass' }
    if ret != expect
      t.error("expect exec output not change from #{expect} got #{ret}")
    end
    unless PG::Connection::GeneralLog.general_log.first.format =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'hoge'\t\[\]$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format}`")
    end
    unless PG::Connection::GeneralLog.general_log.first.format(true) =~ /^SQL\t\(\d+\.\d+ms\)\tSELECT \* FROM users WHERE name = 'hoge'\t\[\].+in `test_async_values'$/
      t.error("expect log format not correct got `#{PG::Connection::GeneralLog.general_log.first.format(true)}`")
    end
  end

  def test_log_class(t)
    if PG::Connection::GeneralLog::Log.members != %i[sql args backtrace time]
      t.error("expect PG::Connection::GeneralLog::Log.members is [:sql, :args, :backtrace, :time] got #{PG::Connection::GeneralLog::Log.members}")
    end
  end

  def example_general_log
    db_init
    @client.exec("SELECT * FROM users WHERE name = '#{'hoge'}'")
    @client.exec_params('SELECT * FROM users WHERE name = $1', ['hoge'])

    @client.prepare('select2', 'SELECT * FROM users WHERE name = $1')
    @client.exec_prepared('select2', ['bar'])
    @client.exec_prepared('select2', ['foo'])
    puts PG::Connection::GeneralLog.general_log.map { |log| [log.sql, log.args.to_s, log.backtrace.find{|c| %r{/gems/} !~ c.to_s}.to_s.gsub(/.*?:/, '')].join(' ') }
    # Output:
    # SELECT * FROM users WHERE name = 'hoge' [] in `example_general_log'
    # SELECT * FROM users WHERE name = $1 ["hoge"] in `example_general_log'
    # SELECT * FROM users WHERE name = $1 ["bar"] in `example_general_log'
    # SELECT * FROM users WHERE name = $1 ["foo"] in `example_general_log'
  end
end
