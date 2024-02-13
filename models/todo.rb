class Todo < Common
  def self.header
    super.merge(
      date: { name: '日付', allow_nil: false, option: false },
      todo: { name: 'TODO', allow_nil: true, option: false },
    )
  end
end