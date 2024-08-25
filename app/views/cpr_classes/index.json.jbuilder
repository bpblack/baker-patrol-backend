json.classes @classes.each do |c|
  json.(c, :id, :students_count, :class_size)
  json.time c.time_str
  json.classroom do
    json.id c.cr_id
    json.name c.cr_name
  end
end