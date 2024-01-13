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
# Migrate.stop
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

# CGI.unescape https://github.com/ruby/cgi/blob/929e6264b519a6b6d1487d0ba5cea48579dc3c0d/lib/cgi/util.rb#L27C3-L35C6
def unescape(string)
  str = string.tr('+', ' ')
  str = str.b
  str.gsub!(/((?:%[0-9a-fA-F]{2})+)/) do |m|
    [m.delete('%')].pack('H*')
  end
  str.force_encoding(Encoding::UTF_8)
  str.valid_encoding? ? str : str.force_encoding(string.Encoding::UTF_8)
end

srv.mount_proc('/new') do |req, res|
  if req.query['name'].present?
    User.create(name: unescape(req.query['name']))
    res.set_redirect(WEBrick::HTTPStatus::MovedPermanently, '/')
  end
  res.body = ERB.new( File.read('public/user_new.html.erb') , trim_mode: '-').result
end

User.all.each do |user| #=> TODO 新規作成したユーザーを編集しようとすると404エラーになる。作成したものは、マウントしないからだ。
  srv.mount_proc("/#{user.id}/edit") do |req, res|
    @view_item = user
    if req.query['name'].present? && user.name != (update_value = unescape(req.query['name'])) #=> req.query['name'].encode("UTF-8")でエラーになる理由
      User.update(user.id, name: update_value)
      res.set_redirect(WEBrick::HTTPStatus::MovedPermanently, '/')
    end
    res.body = ERB.new( File.read('public/user_edit.html.erb') , trim_mode: '-').result
  end
end

trap("INT"){ srv.shutdown }
srv.start