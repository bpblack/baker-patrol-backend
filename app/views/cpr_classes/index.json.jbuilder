json.classes @classes.each do |c|
  json.(c, :id, :students_count, :class_size)
  json.time c.time_str
  json.location c.location
end