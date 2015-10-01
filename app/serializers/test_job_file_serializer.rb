class TestJobFileSerializer < ActiveModel::Serializer
  attributes :file_name, :created_at, :id

  belongs_to :test_job
end
