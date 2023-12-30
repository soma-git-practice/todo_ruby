class User < Common
  @header = {
    id: { name: 'ID', option: true },
    name: { name: '名前', allow_nil: false, option: false },
    delete: { name: '削除', allow_nil: true, option: true },
  }
end