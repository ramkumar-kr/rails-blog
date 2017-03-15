FactoryGirl.define do
  factory :comment do
    commenter { Faker::StarWars.character }
    body { Faker::StarWars.quote }
    article
  end
end
