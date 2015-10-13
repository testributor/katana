class ProjectFileSerializer < ActiveModel::Serializer
  attributes :id, :path, :contents
end
