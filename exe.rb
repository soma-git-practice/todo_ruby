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

Todo.export