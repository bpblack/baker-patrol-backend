json.classes @classes.each do |c|
  json.(c, :id, :students_count, :class_size)
  json.time c.time_str
  json.location c.location
  json.students c.sorted_students do |s|
    json.(s, :id, :first_name, :last_name, :email, :cpr_class_id)
  end
end