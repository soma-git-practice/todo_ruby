# gems
require 'active_record'
require 'csv'
require 'pry'

# # 共通ファイル
require_relative 'common'
# # ここでcsv系を追加しておきたい

# # モデル読み込む
require_relative 'models/todo'
require_relative 'models/user'

# # マイグレーションのON
# Migrate.start

# # サンプルデータ読み込み
# Todo.setup

# Todo.import('import.csv')

# # マイグレーションOFF
# Migrate.stop



# csv/import内の全パスを取得する
Dir.children('csv/samples')
# ファイル名からモデルを絞り込む　なければ異物混入警報発令
p Dir.children('csv/samples').map{|name| name[/.*(?=\.)/].classify.constantize}