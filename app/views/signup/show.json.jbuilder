json.student do
  json.name @cprs.student.name
  json.cpr_class_id @cprs.cpr_class_id
  json.has_cpr_cert @cprs.has_cpr_cert
end
json.classes do
  json.array! @classes do |c|
    json.(c, :id, :students_count, :class_size)
    json.time c.time_str
    json.classroom do
      json.id c.cr_id
      json.name c.cr_name
    end
  end
end
