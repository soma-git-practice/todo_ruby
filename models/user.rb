class User < Common
  def self.header
    super.merge(
      name: { name: '名前', allow_nil: false, option: false }
    )
  end
end