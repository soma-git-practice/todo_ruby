require 'date'

# | sund | mond | tues | wedn | thur | frid | satu |
# |      |      |      |      |  01  |  02  |  03  |
# |  04  |  05  |  06  |  07  |  08  |  09  |  10  |
# |  11  |  12  |  13  |  14  |  15  |  16  |  17  |
# |  18  |  19  |  20  |  21  |  22  |  23  |  24  |
# |  25  |  26  |  27  |  28  |  29  |      |      |

origin = Date.today
# origin_ym = origin.year, origin.month
origin_ym = 2024, 2

begining_of_the_month = Date.new(*origin_ym, +1)
ending_of_the_month   = Date.new(*origin_ym, -1)

during = begining_of_the_month..ending_of_the_month

# ↓気に入らない
w = ['SUND', 'MOND', 'TUES', 'WEDE', 'THUR', 'FRID', 'SATU']
w += (0...during.first.wday).map{ '  ' } + during.map { |day| "%02d" % day.day } + Array.new(6 - during.last.wday, '  ')
# ↑気に入らない

# 最大文字数を計算
max_value = w.map(&:length).max

# 中央寄せ
result = w.map { |item| item.center(max_value + 2) }

# 7分割
result = result.each_slice(7).map do |item|
  "|" + item * "|" + "|"
end

puts result