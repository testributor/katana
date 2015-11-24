class ProjectFile < ActiveRecord::Base
  BUILD_COMMANDS_PATH = 'testributor_build_commands.sh'
  JOBS_YML_PATH = "testributor.yml"

  belongs_to :project

  # Let build_commands be empty
  validates :contents, :path, presence: true,
    unless: ->{ path == BUILD_COMMANDS_PATH }
  validates :path, uniqueness: { scope: :project_id }
  validate :valid_contents, if: :testributor_yml?
  # testributor.yml and build_commands should not be deleted
  before_destroy -> { return false }, if: :testributor_yml?
  before_destroy -> { return false }, if: :build_commands?
  validate :prevent_path_change,
    if: ->{ path_changed? && (path_was == JOBS_YML_PATH || path_was == BUILD_COMMANDS_PATH) }

  def testributor_yml?
    path == JOBS_YML_PATH
  end

  def build_commands?
    path == BUILD_COMMANDS_PATH
  end

  private

  def valid_contents
    return if contents.blank?
    begin
      jobs_description = YAML.load(contents)
    rescue Psych::SyntaxError
      errors.add(:contents, :syntax_error)
      return
    end

    unless jobs_description.is_a?(Hash)
      errors.add(:contents, :no_key_provided)
      return
    end

    if jobs_description.has_key?("each")
      each_description = jobs_description.delete("each")

      unless each_description
        errors.add(:contents, :each_without_pattern)
        errors.add(:contents, :each_without_command)
        return
      end

      unless each_description["pattern"]
        errors.add(:contents, :each_without_pattern)
        return
      end

      unless each_description["command"]
        errors.add(:contents, :each_without_command)
        return
      end
    end

    jobs_description.each do |job_name, description|
      unless description.try(:[],"command")
        errors.add(:contents, "#{job_name} is missing \"command\" key")
        return
      end
    end
  end

  def prevent_path_change
    errors.add(:path, "Cannot change path for this file")
  end
end
