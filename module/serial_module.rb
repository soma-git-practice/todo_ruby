module Serial
  def counter
    count = 0
    ->{
      count += 1
    }
  end

  def up
    @up = counter unless instance_variables.include?(:@up)
    @up.call
  end
end

# class User
#   extend Serial
#   attr_reader :id
#   def initialize(name)
#     @id = self.class.up
#     @name = name
#   end
# end 

# User.new.id #=> 1
# User.new.id #=> 2