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

# マイグレーションのON
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
class UserERBHandler < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, name)
    super(server, name)
    @script_filename = name
  end

  def do_GET(req, res)
    data = File.open(@script_filename, &:read)
    res.body = ERB.new(data, trim_mode: '-').result
    res['content-type'] ||= WEBrick::HTTPUtils::mime_type(@script_filename, @config[:MimeTypes])
  end
end
WEBrick::HTTPServlet::FileHandler.add_handler("erb", UserERBHandler)

srv = WEBrick::HTTPServer.new({ DocumentRoot: 'public', DirectoryIndex: ['user.html.erb'], :BindAddress => '127.0.0.1', :Port => 20080, :ServerName => 'マイサーバー' })
srv.mount_proc('/new') do |req, res|
  res.status = 200
  res.content_type = 'text/html'
  res.body = ERB.new( File.read('public/user_new.html.erb') , trim_mode: '-').result

  if req.query['name'].present?
    binding.pry
    # マルチバイト文字（あ）を送信すると、エラーになる

    # User.create(name: req.query['name'])
    # 
    # リクエストメソッドをpostからgetにする
    # res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, "/")
    res.set_redirect(WEBrick::HTTPStatus::MovedPermanently, '/')
  end
end

trap("INT"){ srv.shutdown }
srv.start
