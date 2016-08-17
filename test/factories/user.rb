FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
    confirmed_at Date.current
    projects_limit 1
    github_access_token "6958771a03001a069b7d1952cb2404485f4ef35d"
  end

  factory :bitbucket_user, class: User do
    sequence(:email) { |n| "bitbucket_person#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
    confirmed_at Date.current
    projects_limit 1
    bitbucket_access_token "J6B4ZrAufuFc4LNzju"
    bitbucket_access_token_secret "hq2NZbvXVC23TSxDCJBXB4yr8Yfu9cvP"
  end

  trait :with_github_public_repo_access do
    github_access_token "d903e23e744fc5eb78666137fe1afdd604ffc859"
  end

  trait :without_svc_access do
    github_access_token nil
  end
end
