json.students @students.each do |s|
  json.(s, :id, :first_name, :last_name, :email, :cpr_class_id)
end