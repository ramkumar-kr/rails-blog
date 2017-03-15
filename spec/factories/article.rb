FactoryGirl.define do
  factory :article do
    title { Faker::StarWars.character }
    text { Faker::StarWars.quote }

    trait :with_comments do
      after(:create) do |article, _evaluator|
        build_list(:comment, 3, article: article)
      end
    end

    factory :user_with_comments, traits: [:with_comments]
  end
end
