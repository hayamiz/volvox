Factory.define :opt_column do |col|
  col.name			"Weight [g]"
  col.col_type			OptColumn::COL_FLOAT
end

Factory.sequence :col_name do |n|
  "Column #{n}"
end
