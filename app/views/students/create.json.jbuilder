json.(@student, :id, :cpr_class_id, :has_cpr_cert)
json.first_name @student.student.first_name
json.last_name @student.student.last_name
json.email @student.student.email
json.modifiable @student.modifiable()
