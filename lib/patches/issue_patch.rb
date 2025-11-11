module RedmineIssueEvm
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      after_commit :clear_evm_cache_for_project

      private

      def clear_evm_cache_for_project
        return unless project_id.present?
        Rails.cache.delete_matched("admin_evm_dashboard_#{project_id}_*")
      end
    end
  end
end
