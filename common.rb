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
      t.string :date #日付
      t.string :todo #TODO
    end
    
    create_table :users do |t|
      t.string :name    #名前
    end
    puts 'Migrate START'
  end

  def self.stop
    drop_table :todos
    drop_table :users
    puts 'Migrate STOP'
  end
end


class Common < ActiveRecord::Base
  self.abstract_class = true #この一行重要

  def self.header
    {
      id: { name: 'ID', option: true },
      delete: { name: '削除', allow_nil: true, option: true },
    }
  end

  def self.export
    unless connection.table_exists?(self.name.downcase.pluralize)
      p self.name + "テーブルはデータベースはありません。"
      return
    end

    if self.all.blank?
      p self.name + "テーブルは空っぽです。"
      return
    end

    keys = self.header.keys
    column = CSV::Row.new(keys.map { |sym| self.header[sym][:name] }, [], header_row: true)
    row = self.all.map do |record|
      value = keys.each_with_object({title: [], body: []}) do |key, hash|
                    hash[:title] << self.header[key][:name]
                    hash[:body] << record[key]
                  end
      CSV::Row.new( value[:title], value[:body])
    end
    CSV::Table.new([column, *row])
  end

  def self.import(csv_data)
    unless connection.table_exists?( self.name.downcase.pluralize )
      p "#{self}テーブルはデータベースはありません。" 
      return
    end

    csv_data.each do |csv|
      if csv[header[:delete][:name]].present? && csv[header[:id][:name]].present?
        # 削除
          target = find_by(id: csv[header[:id][:name]])
          next target.delete if target.present?
          puts "ID：#{csv[header[:id][:name]]}がデータベースに存在していないため削除できません。"
        # 削除
      elsif csv[header[:delete][:name]].present?
        # その他
          puts '削除にはIDが必要'
        # その他
      elsif csv[header[:id][:name]].present?
        # 編集
          # 更新するデータの取得
          target = find_by(id: csv[header[:id][:name]])
          next puts "ID：#{csv[header[:id][:name]]}がデータベースに存在していないため編集できません。" if target.blank?
          # 更新の際に使用する
          update_hash = Hash.new
          header.keys.each do |sym|
            # optionがtrueの場合、 更新前のデータと更新用のデータが等しい場合
            next if header[sym][:option] || target[sym] == csv[header[sym][:name]]
            # 条件 = 空を許さない && 更新用のデータが空の場合
            conditions = header[sym][:allow_nil] == false && csv[header[sym][:name]].blank?
            return puts "#{header[sym][:name]}：何か入力して" if conditions
            update_hash[sym] = csv[header[sym][:name]]
          end
          if update_hash.present?
            update_keywords = update_hash.keys.map{|sym| header[sym][:name]}
            puts "id: #{target.id} の「#{update_keywords.join('、')}」を変更しました。"
            target.update(update_hash)
          else
            puts "#{target.id}に変更はありません。"
          end
        # 編集
      else
        # 作成
          create_attributes = Hash.new
          header.keys.each do |sym|
            next if header[sym][:option]
            return p "#{header[sym][:name]}：何か入力して" if header[sym][:allow_nil] == false && csv[header[sym][:name]].blank?
            create_attributes[sym] = csv[header[sym][:name]]
          end
          create create_attributes
          p "レコードを作成しました"
        # 作成
      end
    end
  end
end