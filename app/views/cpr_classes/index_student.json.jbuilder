json.classes @classes.each do |c|
  json.(c, :id, :students_count, :class_size)
  json.time c.time_str
  json.classroom do
    json.id c.cr_id
    json.name c.cr_name
  end
  json.students c.sorted_students do |s|
    json.(s, :id, :cpr_class_id, :has_cpr_cert)
    json.first_name s.student.first_name
    json.last_name s.student.last_name
    json.email s.student.email
    json.modifiable s.modifiable()
  end
end