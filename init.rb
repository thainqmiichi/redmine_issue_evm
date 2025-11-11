require "redmine"
require "holidays/core_extensions/date"
require_relative "lib/evm_permission_helper"
include EvmPermissionHelper

# Extention for ate class
class Date
  include Holidays::CoreExtensions::Date
end

# for search and activity page
if Rails.version > "6.0" && Rails.autoloaders.zeitwerk_enabled?
  Redmine::Activity.register "evmbaseline"
  Redmine::Activity.register "project_evmreport"
  Redmine::Search.available_search_types << "evmbaselines"
  Redmine::Search.available_search_types << "project_evmreports"
else
  Rails.configuration.to_prepare do
    Redmine::Activity.register "evmbaseline"
    Redmine::Activity.register "project_evmreport"
    Redmine::Search.available_search_types << "evmbaselines"
    Redmine::Search.available_search_types << "project_evmreports"
  end
end

# module define
Redmine::Plugin.register :redmine_issue_evm do
  name "Redmine Issue Evm plugin"
  author "Hajime Nakagama"
  description "Earned value management calculation plugin."
  version "6.0.2"
  url "https://github.com/momibun926/redmine_issue_evm"
  author_url "https://github.com/momibun926"
  project_module :Issuevm do
    permission :view_evms, evms: :index, require: :member
    permission :manage_evmbaselines,
               evmbaselines: %i[edit destroy new create update index show history]
    permission :view_evmbaselines,
               evmbaselines: %i[index history show]
    permission :manage_evmsettings,
               evmsettings: %i[ndex edit]
    permission :view_project_evmreports,
               evmreports: %i[index show new create edit destroy]
    permission :view_evm_reports_summary,
               evm_reports_summary: %i[index], global: true
  end

  # menu
  menu :project_menu, :issuevm, { controller: :evms, action: :index },
       caption: :tab_display_name, param: :project_id

  # top menu (admin dashboard) - trên top menu
  menu :top_menu, :admin_evm_dashboard, { controller: :admin_evm_dashboard, action: :index },
       caption: :label_evm_admin_dashboard, if: Proc.new { can_view_evm? }

  # application menu (admin dashboard) - sau News
  menu :application_menu, :admin_evm_dashboard, { controller: :admin_evm_dashboard, action: :index },
       caption: :label_evm_admin_dashboard, if: Proc.new { can_view_evm? }

  # EVM Reports Summary menu
  menu :top_menu, :evm_reports_summary, { controller: :evm_reports_summary, action: :index },
       caption: :label_evm_reports_summary, if: Proc.new { can_view_evm? }

  menu :application_menu, :evm_reports_summary, { controller: :evm_reports_summary, action: :index },
       caption: :label_evm_reports_summary, if: Proc.new { can_view_evm? }

  # load holidays
  Holidays.load_all
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push(
    :evm_admin_dashboard_sidebar,
    { controller: 'admin_evm_permissions', action: 'index' },
    caption: 'EVM permissions',
    icon: 'roles',
    html: { class: 'icon' }
  )
end

Rails.application.config.after_initialize do
  require_dependency File.expand_path('lib/patches/project_patch', __dir__)
  require_dependency File.expand_path('lib/patches/issue_patch', __dir__)
  require_dependency File.expand_path('lib/patches/time_entry_patch', __dir__)

  Project.include RedmineIssueEvm::ProjectPatch unless Project.included_modules.include?(RedmineIssueEvm::ProjectPatch)
  Issue.include RedmineIssueEvm::IssuePatch unless Issue.included_modules.include?(RedmineIssueEvm::IssuePatch)
  TimeEntry.include RedmineIssueEvm::TimeEntryPatch unless TimeEntry.included_modules.include?(RedmineIssueEvm::TimeEntryPatch)
end
