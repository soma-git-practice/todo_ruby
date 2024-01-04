# gems
require 'active_record'
require 'csv'
require 'pry'
require 'webrick'
require 'erb'

# # 共通ファイル
require_relative 'common'
# # ここでcsv系を追加しておきたい

# # モデル読み込む
require_relative 'models/todo'
require_relative 'models/user'

# # マイグレーションのON
# Migrate.start

@users = User.all

# webサーバー作成
# srv = WEBrick::HTTPServer.new({ :DocumentRoot => './index.html', :BindAddress => '127.0.0.1', :Port => 20080})
# trap("INT"){ srv.shutdown }
# srv.start

# # マイグレーションOFF
# Migrate.stop