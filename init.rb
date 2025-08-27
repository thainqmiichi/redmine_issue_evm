require "redmine"
require "holidays/core_extensions/date"

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

# Helper method để kiểm tra quyền EVM
def can_access_evm_admin_dashboard?
  return true if User.current.admin?
  
  user_roles = User.current.roles_for_project(Project.new)
  user_roles.any? { |role| EvmRolePermission.can_access_admin_dashboard?(role.id) }
end

def can_access_evm_reports_summary?
  return true if User.current.admin?
  
  user_roles = User.current.roles_for_project(Project.new)
  user_roles.any? { |role| EvmRolePermission.can_access_reports_summary?(role.id) }
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
       caption: :label_evm_admin_dashboard, if: Proc.new { can_access_evm_admin_dashboard? }

  # application menu (admin dashboard) - sau News
  menu :application_menu, :admin_evm_dashboard, { controller: :admin_evm_dashboard, action: :index },
       caption: :label_evm_admin_dashboard, if: Proc.new { can_access_evm_admin_dashboard? }

  # EVM Reports Summary menu
  menu :top_menu, :evm_reports_summary, { controller: :evm_reports_summary, action: :index },
       caption: :label_evm_reports_summary, if: Proc.new { can_access_evm_reports_summary? }

  menu :application_menu, :evm_reports_summary, { controller: :evm_reports_summary, action: :index },
       caption: :label_evm_reports_summary, if: Proc.new { can_access_evm_reports_summary? }

  # EVM Settings menu (chỉ admin)
  menu :admin_menu, :evm_settings, { controller: :evm_settings, action: :index },
       caption: :label_evm_settings, html: { class: 'icon icon-settings' }, if: Proc.new { User.current.admin? }

  # load holidays
  Holidays.load_all
end
