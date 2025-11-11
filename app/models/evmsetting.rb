# evm setting model
class Evmsetting < ActiveRecord::Base
  # Relations
  belongs_to :project
  after_commit :clear_evm_cache

  private

  def clear_evm_cache
    return unless project_id.present?
    Rails.cache.delete_matched("admin_evm_dashboard_#{project_id}_*")
  end

  # Validate
  validates :etc_method,
            presence: true

  validates :basis_hours,
            presence: true,
            numericality: { greater_than: 0 }

  validates :threshold_spi,
            presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: 0.99 }

  validates :threshold_cpi,
            presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: 0.99 }

  validates :threshold_cr,
            presence: true,
            numericality: { greater_than: 0, less_than_or_equal_to: 0.99 }

  validates :region,
            presence: true
end
