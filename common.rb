# データベース接続作成
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/todo.db'
)

# データベース接続
$connection = ActiveRecord::Base.connection

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
    
    # create_table :users do |t|
    #   t.string :name    #名前
    # end
    puts 'Migrate START'
  end

  def self.stop
    drop_table :todos
    # drop_table :users
    puts 'Migrate STOP'
  end

  def self.switch
    $connection.table_exists?(:todos) ? stop : start
  end
end


class Common < ActiveRecord::Base
  self.abstract_class = true #この一行重要

  def self.export
    return p "#{self}テーブルはデータベースはありません。" unless $connection.table_exists?( self.name.downcase.pluralize )
    return p "#{self}テーブルは空っぽです。" if all.blank?

    header_keys = @header.keys
    csv_header = header_keys.map{|sym| @header[sym][:name]}
    FileUtils.mkdir_p('csv/exports')
    CSV.open("csv/exports/#{self.name.downcase}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv", 'w') do |csv|
      csv << csv_header
      all.each{|record| csv << header_keys.map{|sym| record[sym]}}
    end
  end
end