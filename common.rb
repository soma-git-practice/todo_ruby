# データベース接続作成
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/todo.db'
)

# データベース接続
connection = ActiveRecord::Base.connection

# テーブル操作
class Migrate < ActiveRecord::Migration[7.0]
  def self.start
    create_table :todos do |t|
      t.string :subject #だれが
      t.string :place   #どこで
      t.string :object  #なにを
      t.string :verb    #どうする
      t.string :s_time  #いつから
      t.string :e_time  #いつまで
    end
    puts 'Migrate START'
  end

  def self.stop
    drop_table :todos
    puts 'Migrate STOP'
  end

  def self.switch
    connection.table_exists?(:todos) ? stop : start
  end
end