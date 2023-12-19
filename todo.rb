require 'active_record'
require 'csv'
require 'pry'

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


class Todo < ActiveRecord::Base
  def self.arrange_time(year,month,day,hour,min)
    Time.new(year, month, day, hour, min).strftime('%Y-%m-%d %H:%M')
  end

  # 初期データ作成
  def self.setup
    # テーブルが存在していれば
    return unless connection.table_exists?(:todos)
    # DB内にレコードが存在しない場合のみ
    return if all.present?
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

    CSV.open(file_path, 'r', headers: true).each do |csv|
      if csv['id'].present? && csv['delete'].present?
        # 削除
        puts "#{ csv['id'] }を削除しました。"
        destroy(csv['id']) if where(id: csv['id']).present?
      elsif csv['id'].present?
        # 編集
        target = where(id: csv['id']).first
        attr = {}
        arr = []
        # 誰が
        if csv['だれが'].present? && csv['だれが'] != target[:subject]
          attr[:subject] = csv['だれが']
          arr << 'だれが'
        end
        # どこで
        if csv['どこで'].present? && csv['どこで'] != target[:place]
          attr[:place] = csv['どこで']
          arr << 'どこで'
        end
        # なにを
        if csv['なにを'].present? && csv['なにを'] != target[:object]
          attr[:object] = csv['なにを']
          arr << 'なにを'
        end
        # どうする
        if csv['どうする'].present? && csv['どうする'] != target[:verb]
          attr[:verb] = csv['どうする']
          arr << 'どうする'
        end
        # いつから
        if csv['いつから'] != target[:s_time]
          attr[:s_time] = csv['いつから']
          arr << 'いつから'
        end
        # いつまで
        if csv['いつまで'] != target[:e_time]
          attr[:e_time] = csv['いつまで']
          arr << 'いつまで'
        end
        target.update(attr)
        puts "#{csv['id']}を編集しました。#{arr}" if arr.present?
        puts "#{csv['id']}に変更はありません。" if arr.blank?
      else
        puts "新規作成しました。"
        create(
          subject: csv["だれが"],
          place: csv["どこで"],
          object: csv["なにを"],
          verb: csv["どうする"],
          s_time: csv["いつから"],
          e_time: csv["いつまで"]
        )
      end
    end
  end

end

# マイグレーションのON・OFFスイッチ
# Migrate.switch
# Migrate.switch
# 初期データ作成
Todo.setup

# switch switch setupで毎回リセット

Todo.import('csv/import.csv')