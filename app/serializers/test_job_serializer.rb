class TestJobSerializer < ActiveModel::Serializer
  attributes :command, :created_at, :id

  belongs_to :test_run
end
