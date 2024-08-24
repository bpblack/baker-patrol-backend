json.array! @years do |y|
  json.(y, :id)
  json.year y.year.strftime('%Y')
  if y.year.year < Date.today.year
    json.expired true
  else
    json.expired false
  end
end