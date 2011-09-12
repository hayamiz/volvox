Factory.define :entry do |entry|
  entry.date		Date.new(2011, 9, 12)
  entry.temperature	23.4
  entry.humidity	50.0
  entry.action_feed	"Gave food a lot"
  entry.action_care	"Cleaned up the cage"
  entry.pet_feces	"So much"
  entry.pet_physical	"Very good"
  entry.memo		"so sunny day"
end

Factory.define :empty_entry, :class => Entry do |entry|
  entry.date		Date.today
end


Factory.sequence :date do |n|
  Date.today + n + 1
end
