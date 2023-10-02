json.students @students.each do |s|
  json.(s, :id, :email, :cpr_class_id)
  json.name s.name
end