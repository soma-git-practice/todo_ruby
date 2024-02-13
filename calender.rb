require 'date'

origin = Date.today
origin_ym = origin.year, origin.month

begining_of_the_month = Date.new(*origin_ym, +1)
ending_of_the_month   = Date.new(*origin_ym, -1)

during = begining_of_the_month..ending_of_the_month

day_hash = during.group_by(&:wday)
day_array = (0..6).map{|i| day_hash[i]}

day_array.each do |item|
  break if item.first.day == 1
  item.prepend ''
end

@value = day_array.map do |item|
  item.map do |item_2|
    {
      date: if item_2.is_a?(Date)
              item_2
            else
              ''
            end,
      todo: ''
    }
  end
end