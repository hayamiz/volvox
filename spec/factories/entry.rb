Factory.define :entry do |entry|
  entry.title	"The first entry for testing"
  entry.content	Faker::Lorem.sentence(10)
end
