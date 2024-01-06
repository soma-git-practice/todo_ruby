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
srv = WEBrick::HTTPServer.new({ :DocumentRoot => './index.html', :BindAddress => '127.0.0.1', :Port => 20080})
srv.mount_proc('/') do |_req, res|
  body = ERB.new(<<~'EOS', trim_mode: '-').result
  <!DOCTYPE html>
  <html lang='en'>
    <head>
      <meta charset='UTF-8'>
      <meta name='viewport' content='width=device-width, initial-scale=1.0'>
      <title></title>
    </head>
    <body>
      <h1>参加者一覧</h1>
      <ul>
        <%- User.all.each do |item| -%>
        <li><%= item.name %></li>
        <%- end -%>
      </ul>
    </body>
  </html>
  EOS

  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

trap("INT"){ srv.shutdown }
srv.start

# # マイグレーションOFF
# Migrate.stop