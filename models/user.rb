class User < Common
  @header = {
    id:      { name: 'ID' },
    name:    { name: '名前',     allow_nil: false, option: false },
  }
end