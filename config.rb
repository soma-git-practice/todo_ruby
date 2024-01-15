module ServerConfig
  def self.data
    {
      DocumentRoot: 'public',
      DirectoryIndex: ['user.html.erb'],
      BindAddress: '127.0.0.1',
      Port: 20080,
      ServerName: 'マイサーバー'
    }
  end
end