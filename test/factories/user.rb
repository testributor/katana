FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
    confirmed_at Date.current
    projects_limit 1
    encrypted_github_access_token "Mw77WrzI2zywus5kPmpt+abo9UPMgIY6zCowzAFrf3kxDCyWVk8LMH7vLyUh\ngKr1\n"
    encrypted_github_access_token_salt "c5301a0e89a217ab"
    encrypted_github_access_token_iv "7Q6SiUycJvz+S6/6mXhGQg==\n"
  end
end
