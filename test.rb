10.times do |i|
  if i == 2 #iが1のときに
    next # ループを1回スキップする
  elsif i == 4
    next
  elsif i == 6
    break
  end
  puts "#{i}: hello"
end
