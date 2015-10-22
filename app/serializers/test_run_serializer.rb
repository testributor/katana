class TestRunSerializer < ActiveModel::Serializer
  attributes :commit_sha, :id
  
  belongs_to :project
end
