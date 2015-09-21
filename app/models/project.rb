class Project < ActiveRecord::Base
  has_many :tracked_branches, dependent: :destroy

  attr_accessor :fork
end
