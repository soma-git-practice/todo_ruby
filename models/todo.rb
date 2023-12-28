class Todo < Common
  @header = {
    id:      { name: 'ID' },
    subject: { name: 'だれが',   allow_nil: false, option: false },
    place:   { name: 'どこで',   allow_nil: false, option: false },
    object:  { name: 'なにを',   allow_nil: false, option: false },
    verb:    { name: 'どうする',  allow_nil: false, option: false },
    s_time:  { name: 'いつから',  allow_nil: true,  option: false },
    e_time:  { name: 'いつまで',  allow_nil: true,  option: false },
    delete:  { name: '削除',     allow_nil: true,  option: true },
  }
end