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
    puts 'Migrate START'
  end

  def self.stop
    drop_table :todos
    puts 'Migrate STOP'
  end

  def self.switch
    $connection.table_exists?(:todos) ? stop : start
  end
end

HEADER = {
  todo: {
    id:      { name: 'ID' },
    subject: { name: 'だれが',   allow_nil: false, option: false },
    place:   { name: 'どこで',   allow_nil: false, option: false },
    object:  { name: 'なにを',   allow_nil: false, option: false },
    verb:    { name: 'どうする',  allow_nil: false, option: false },
    s_time:  { name: 'いつから',  allow_nil: true,  option: false },
    e_time:  { name: 'いつまで',  allow_nil: true,  option: false },
    delete:  { name: '削除',     allow_nil: true,  option: true },
  },
  user: {}
}

class Common < ActiveRecord::Base
  def self.export
    # テーブルが作成されていない場合引き返す
    table = model_name.plural
    return unless $connection.table_exists?( table )
    FileUtils.mkdir_p('csv/exports')
    file_name = "csv/exports/#{model_name.singular}_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"

    CSV.open(file_name, 'w') do |csv|
      HEADER[model_name.singular.to_sym].each do |key, val|
        csv  << val[:name]
      end
    end
    binding.pry
  end
end