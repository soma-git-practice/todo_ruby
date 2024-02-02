require 'date'
origin = Date.today
origin_ym = origin.year, origin.month

begining_of_the_month = Date.new(*origin_ym, +1)
ending_of_the_month   = Date.new(*origin_ym, -1)

during = begining_of_the_month..ending_of_the_month
# during.find_all do |day|
#   puts day
# end

#  週は七日

# | sund | mond | tues | wedn | thur | frid | satu |
# |      |      |      |      |  01  |  02  |  03  |
# |  04  |  05  |  06  |  07  |  08  |  09  |  10  |
# |  11  |  12  |  13  |  14  |  15  |  16  |  17  |
# |  18  |  19  |  20  |  21  |  22  |  23  |  24  |
# |  25  |  26  |  27  |  28  |  29  |      |      |

puts "| sund | mond | tues | wedn | thur | frid | satu |\n|      |      |      |      |  01  |  02  |  03  |\n|  04  |  05  |  06  |  07  |  08  |  09  |  10  |\n|  11  |  12  |  13  |  14  |  15  |  16  |  17  |\n|  18  |  19  |  20  |  21  |  22  |  23  |  24  |\n|  25  |  26  |  27  |  28  |  29  |      |      |"


# 7回目が#になるコード