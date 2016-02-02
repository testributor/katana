class WorkerGroupSerializer < ActiveModel::Serializer
  attributes :ssh_key_private, :ssh_key_public
end
