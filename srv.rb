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
Migrate.stop
Migrate.start

if User.all.blank?
  User.create(name: '田中太郎')
  User.create(name: '佐藤武')
  User.create(name: '近藤紀子')
  User.create(name: '伊東圭吾')
  User.create(name: '井上佳代子')
  User.create(name: '竹田宏治')
end

include WEBrick #=> TODO：includeとexcludeを学ぶ

# 以下クラス
class UserERBHandler < HTTPServlet::AbstractServlet
  def initialize(server, name)
    super(server, name)
    @script_filename = name
  end

  def do_GET(req, res)
    data = File.open(@script_filename, &:read)
    res.body = ERB.new(data, trim_mode: '-').result
    res['content-type'] ||= HTTPUtils::mime_type(@script_filename, @config[:MimeTypes])
  end
end
HTTPServlet::FileHandler.add_handler("erb", UserERBHandler)


# 以下インスタンス
srv = HTTPServer.new({ DocumentRoot: 'public', DirectoryIndex: ['user.html.erb'], :BindAddress => '127.0.0.1', :Port => 20080, :ServerName => 'マイサーバー' })
trap("INT"){ srv.shutdown }
srv.start