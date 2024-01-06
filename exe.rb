# gems
require 'active_record'
require 'csv'
require 'pry'
require 'webrick'
require 'erb'

# 共通ファイル
require_relative 'common'
require_relative 'models/todo'
require_relative 'models/user'

# # マイグレーションのON
# Migrate.start

if User.all.blank?
  User.create(name: '田中太郎')
  User.create(name: '佐藤武')
  User.create(name: '近藤紀子')
  User.create(name: '伊東圭吾')
  User.create(name: '井上佳代子')
  User.create(name: '竹田宏治')
end

# webサーバー作成
srv = WEBrick::HTTPServer.new({ :DocumentRoot => './views/index.html', :BindAddress => '127.0.0.1', :Port => 20080})
srv.mount_proc('/view') do |_req, res|
  res.status = 200
  res.content_type = 'text/html'
  res.body = ERB.new( File.read('views/user.html.erb') , trim_mode: '-').result
end
trap("INT"){ srv.shutdown }
srv.start

# # マイグレーションOFF
# Migrate.stop