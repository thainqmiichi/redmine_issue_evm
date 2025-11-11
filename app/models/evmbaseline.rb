# baseline model
class Evmbaseline < ActiveRecord::Base
  # Relations
  belongs_to :author, class_name: "User"
  belongs_to :project
  has_many :evmbaselineIssues, dependent: :delete_all
  # Validate
  validates :subject, presence: true
  after_commit :clear_evm_cache

  private

  def clear_evm_cache
    return unless project_id.present?
    Rails.cache.delete_matched("admin_evm_dashboard_#{project_id}_*")
  end

  # Minimum start date of baseline.
  #
  # @return [date] minimum of start date
  def minimum_start_date
    evmbaselineIssues.minimum(:start_date)
  end

  # maximum due date of baseline.
  #
  # @return [date] maximum of due date
  def maximum_due_date
    evmbaselineIssues.maximum(:due_date)
  end

  # BAC of baseline.
  #
  # @return [Numeric] BAC of baseline
  def bac
    evmbaselineIssues.sum(:estimated_hours).round(1)
  end

  # for activity page.
  # acts_as_activity_provider scope: joins(:project),
  #                           permission: :view_evmbaselines,
  #                           type: "evmbaseline",
  #                           author_key: :author_id

  # for search.
  # acts_as_searchable columns: ["#{table_name}.subject", "#{table_name}.description"],
  #                    preload: :project,
  #                    date_column: :updated_on
  # scope
  scope :visible,
        ->(*args) { joins(:project).where(Project.allowed_to_condition(args.shift || User.current, :view_evmbaselines, *args)) }
end
