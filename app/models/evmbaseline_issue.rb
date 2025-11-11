# baseline issue model
class EvmbaselineIssue < ActiveRecord::Base
  # Relations
  belongs_to :evmbaseline
  after_commit :clear_evm_cache

  private

  def clear_evm_cache
    return unless evmbaseline&.project_id.present?
    Rails.cache.delete_matched("admin_evm_dashboard_#{evmbaseline.project_id}_*")
  end
end
