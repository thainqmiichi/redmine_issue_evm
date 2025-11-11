# project evmreport model
class ProjectEvmreport < ActiveRecord::Base
  # Relations
  belongs_to :author, class_name: "User"
  belongs_to :project

  # Validate
  validates :project_id,
            presence: true

  validates :status_date,
            presence: true

  validates :report_text,
            presence: true

  # for activity page.
  # acts_as_activity_provider scope: joins(:project),
  #                           permission: :view_project_evmreports,
  #                           type: "project_evmreport",
  #                           author_key: :author_id

  # for search.
  # acts_as_searchable columns: ["#{table_name}.report_text"],
  #                    preload: :project,
  #                    date_column: :updated_on
  # scope
  scope :list,
        ->(project_id) { where(project_id: project_id).order(status_date: :DESC).order(created_on: :DESC) }

  scope :previus,
        ->(status_date) { where("status_date < ?", status_date) }

  scope :visible,
        ->(*args) { joins(:project).where(Project.allowed_to_condition(args.shift || User.current, :view_project_evmreports, *args)) }

  def evm_spi
    return nil if evm_ev.blank? || evm_pv.blank? || evm_pv.to_f.zero?
    (evm_ev.to_f / evm_pv.to_f).round(2)
  end

  def evm_cpi
    return nil if evm_ev.blank? || evm_ac.blank? || evm_ac.to_f.zero?
    (evm_ev.to_f / evm_ac.to_f).round(2)
  end
end
