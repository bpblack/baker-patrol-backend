json.students @students.each do |s|
  json.(s, :id, :cpr_class_id, :has_cpr_cert)
  json.first_name s.student.first_name
  json.last_name s.student.last_name
  json.email s.student.email
  json.modifiable s.modifiable()
end