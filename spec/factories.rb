FactoryGirl.define do
  factory :user do
    name     "Test Name1"
    email    "teatmail1@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end