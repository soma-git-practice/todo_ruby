require 'active_record'
require 'csv'
require 'pry'

# データベース接続
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/todo.db'
)

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
    ActiveRecord::Base.connection.table_exists?(:todos) ? stop : start
  end
end


class Todo < ActiveRecord::Base
  def self.arrange_time(year,month,day,hour,min)
    Time.new(year, month, day, hour, min).strftime('%Y-%m-%d %H:%M')
  end

  # 初期データ作成
  def self.setup
    # テーブルが存在していれば
    return unless connection.table_exists?(:todos)
    create(subject: 'Aさん', place: 'A書店', object: '本', verb: 'A冊買う', s_time: arrange_time(2023, 12, 17, 13, 0), e_time: arrange_time(2023, 12, 17, 13, 30))
    create(subject: 'Bさん', place: 'B書店', object: '本', verb: 'B冊買う', s_time: arrange_time(2023, 12, 17, 14, 0), e_time: arrange_time(2024, 12, 17, 14, 30))
    create(subject: 'Cさん', place: 'C書店', object: '本', verb: 'C冊買う', s_time: arrange_time(2024, 12, 17, 15, 0), e_time: arrange_time(2024, 12, 17, 15, 30))
  end

  # エクスポート関連
  def self.values_at(obj)
    obj.values_at(:subject, :place, :object, :verb, :s_time, :e_time)
  end

  HEADER = { subject: 'だれが', place: 'どこで', object: 'なにを', verb: 'どうする', s_time: 'いつから', e_time: 'いつまで' }

  def self.export
    # テーブルが作成されていない場合引き返す
    return unless connection.table_exists?(:todos)
    # DB内にレコードが存在しない場合引き返す
    return unless all.present?

    FileUtils.mkdir_p('csv')
    file_name = "csv/e#{ Time.now.strftime('%Y%m%d%H%M%S') }.csv"
    CSV.open(file_name, 'w') do |csv|
      csv << values_at(HEADER)
      all.each{ |row| csv << values_at(row) }
    end
  end

  # インポート関連
  def self.import(file_path)
    # テーブルが作成されていない場合引き返す
    return unless connection.table_exists?(:todos)

    CSV.read(file_path)
  end
end

# マイグレーションのON・OFFスイッチ
# Migrate.switch
# 初期データ作成
# Todo.setup

# Todo.export

# マイグレーション済み
# 現在空の状態

# pp Todo.import('csv/import.csv')