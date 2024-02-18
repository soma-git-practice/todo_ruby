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
require_relative 'config'

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
  User.create(name: '愛知味噌ノ介')
  User.create(name: '長野蕎麦子')
  User.create(name: '札幌魚太郎')
  User.create(name: '東京バナ男')
  User.create(name: '大阪通天閣')
  User.create(name: '沖縄海人')
  User.create(name: '新潟米味')
  User.create(name: '滋賀池丸')
  User.create(name: '山田富士丈')
end

if Todo.all.blank?
  Todo.create(date: Date.today + 1, todo: 'hoge1')
  Todo.create(date: Date.today + 2, todo: 'hoge2')
  Todo.create(date: Date.today + 3, todo: 'hoge3')
  Todo.create(date: Date.today + 4, todo: 'hoge4')
  Todo.create(date: Date.today + 5, todo: 'hoge5')
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

srv = WEBrick::HTTPServer.new(ServerConfig.data)

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

dynamic_mount = ->(item) do
  srv.mount_proc("/#{item.id}/edit") do |req, res|
    @view_item = User.find(item.id)
    if req.query['name'].present? && @view_item.name != (update_value = unescape(req.query['name'])) #=> TODO：req.query['name'].encode("UTF-8")でエラーになる理由
      User.update(@view_item.id, name: update_value)
      res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/')
    end
    res.body = ERB.new( File.read('public/user_edit.html.erb') , trim_mode: '-').result
  end
  srv.mount_proc("/#{item.id}/delete") do |req, res|
    User.delete(item.id)
    srv.unmount("/#{item.id}/edit")
    srv.unmount("/#{item.id}/delete")
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/') #=> メモ：301リダイレクトはキャッシュが残る
  end
end

# 追加
srv.mount_proc('/new') do |req, res|
  if req.query['name'].present?
    user = User.create(name: unescape(req.query['name']))
    dynamic_mount.call(user)
    res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/')
  end
  res.body = ERB.new( File.read('public/user_new.html.erb') , trim_mode: '-').result
end

User.all.each(&dynamic_mount)

# ajax
srv.mount_proc('/ajax') do |req, res|
  if req.query['page'].present?
    all_user = User.all
    split_users = all_user.each_slice(req.query['per'].to_i).to_a
    users = split_users[req.query['page'].to_i - 1]
    users = users.each_with_object({total: split_users.size, items: {}}) do |user,hash|
              hash[:items][user.id] = user.name
            end
    res.body = JSON[users]
  end
end

# CSV Export
srv.mount_proc('/export') do |req, res|
  res.header["Content-Disposition"] = 'attachment;filename="users.csv"'
  res.header["Content-Type"] = "text/csv"
  res.body = User.export.to_csv
end

# CSV Import
srv.mount_proc('/import') do |req, res|
  recieve = unescape req.query['avatar']
  recieve = CSV.new(recieve, headers: true).read
  User.import recieve
  res.set_redirect(WEBrick::HTTPStatus::SeeOther, '/')
end

# Calendar
srv.mount_proc('/calendar') do |req, res|
  if query = req.query
    year  = query["year"].to_i if query["year"].present?
    month = query["month"].to_i if query["month"].present?
  end

  origin = Date.today
  year ||= origin.year
  month ||= origin.month
  begining_of_the_month = Date.new(year, month, +1)
  ending_of_the_month   = Date.new(year, month, -1)
  during = begining_of_the_month..ending_of_the_month

  day_hash = during.group_by(&:wday)
  day_array = (0..6).map{|i| day_hash[i]}
  day_array.each do |item|
    break if item.first.day == 1
    item.prepend ''
  end

  index = count = 0
  @value = []
  while true
    break if day_array[index % 7][count] == nil
    if day_array[index % 7][count].is_a?(Date)
      @value << {
        date: day_array[index % 7][count].day,
        todo: Todo.find_by(date: day_array[index % 7][count]).try(:todo)
      }
    else
      @value << {
        date: nil,
        todo: nil
      }
    end
    index += 1
    count += 1 if index > 6 && index % 7 == 0
  end
  @value = @value.each_slice(7).to_a
  @month = month
  @style = ["destyle", "calendar"]
  @body  = ERB.new( File.read('public/calendar.html.erb') , trim_mode: '-').result
  res.body = ERB.new( File.read('public/template.html.erb') , trim_mode: '-').result
end

trap("INT"){ srv.shutdown }
srv.start