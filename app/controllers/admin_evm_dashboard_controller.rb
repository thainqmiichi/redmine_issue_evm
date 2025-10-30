# Admin EVM Dashboard Controller
# This controller provides admin view for all projects EVM information
#
require_relative '../../lib/calculate_evm_logic'
require_relative '../../lib/evm_util'
require_relative '../../lib/issue_data_fetcher'

class AdminEvmDashboardController < ApplicationController
  helper EvmReportsSummaryHelper
  include EvmUtil
  include IssueDataFetcher
  include EvmPermissionHelper
  
  # Before action
  before_action :require_evm_permission
  before_action :set_basis_date

  def require_evm_permission
    render_403 unless can_view_evm?(User.current)
  end
  
  # View of admin dashboard page
  def index
    # Admin sees all projects by original logic; non-admins are filtered by roles.can_view_evm
    if User.current.admin?
      @projects = Project.visible.active.order(:name)
    else
      @projects = evm_viewable_projects(Project.visible.active)
    end
    @projects_evm_data = []
    
    @projects.each do |project|
      begin
        evm_data = calculate_project_evm(project)
        @projects_evm_data << evm_data if evm_data
      rescue => e
        Rails.logger.error "Error calculating EVM for project #{project.name}: #{e.message}"
        next
      end
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  private
  
  def require_admin
    unless User.current.admin?
      render_403
      return false
    end
  end
  
  def set_basis_date
    @basis_date = params[:basis_date].present? ? Date.parse(params[:basis_date]) : Date.current
  end
  
  def calculate_project_evm(project)
    # Get EVM setting for project
    evm_setting = Evmsetting.find_by(project_id: project.id)
    return nil unless evm_setting
    
    # Get baseline
    baseline = Evmbaseline.where(project_id: project.id).order(:created_on).last
    
    # Get issues
    issues = evm_issues(project)
    return nil if issues.blank?
    
    # Get actual costs
    actual_cost = evm_costs(project)
    
    # Calculate EVM
    cfg_param = {
      basis_date: @basis_date,
      working_hours: evm_setting.basis_hours,
      exclude_holidays: evm_setting.exclude_holidays
    }
    
    # If no baseline, create empty baseline or use nil
    baselines = baseline ? [baseline] : []
    project_evm = CalculateEvmLogic::CalculateEvm.new(baselines, issues, actual_cost, cfg_param)
    
    # Return EVM data
    {
      project: project,
      status_date: @basis_date,
      status_date_value: project_evm.today_pv,
      variance: project_evm.today_sv,
      performance: project_evm.today_cv,
      forecast: project_evm.today_cv,
      bac: project_evm.bac,
      complete_ev: project_evm.complete_ev,
      pv: project_evm.today_pv,
      ev: project_evm.today_ev,
      ac: project_evm.today_ac,
      sv: project_evm.today_sv,
      cv: project_evm.today_cv,
      spi: project_evm.today_spi,
      cpi: project_evm.today_cpi,
      cr: project_evm.today_cr,
      eac: project_evm.eac,
      etc: project_evm.etc,
      vac: project_evm.vac,
      tcpi: project_evm.tcpi,
      finished_date: project_evm.finished_date,
      working_hours: cfg_param[:working_hours]
    }
  rescue => e
    Rails.logger.error "Error in calculate_project_evm for project #{project.name}: #{e.message}"
    nil
  end
  

end
