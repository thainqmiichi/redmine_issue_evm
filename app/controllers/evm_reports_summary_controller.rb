# EVM Reports Summary Controller
# This controller provides a summary view of all projects EVM reports
#
class EvmReportsSummaryController < ApplicationController
  helper EvmReportsSummaryHelper
  helper EvmreportsHelper
  
  # Before action
  before_action :require_evm_reports_access
  before_action :set_filters
  
  # View of EVM reports summary page
  def index
    # Admin có thể xem tất cả project, user thường chỉ xem project họ có quyền
    if User.current.admin?
      scope = Project.order(:name)
    else
      scope = Project.visible.order(:name)
    end
    
    scope = scope.where(status: @project_status) if @project_status.present?
    
    @projects = scope
    @reports_data = []
    
    @projects.each do |project|
      begin
        # Get latest report in selected week
        latest_report = get_latest_report_in_week(project)
        if latest_report
          # Get previous report
          previous_report = get_previous_report(project, latest_report)
          
          # Get EVM setting for project
          evm_setting = Evmsetting.find_by(project_id: project.id)
          
          # Check if all previous values are zero
          previous_data = {
            bac: previous_report&.evm_bac || 0,
            pv: previous_report&.evm_pv || 0,
            ev: previous_report&.evm_ev || 0,
            ac: previous_report&.evm_ac || 0,
            sv: previous_report&.evm_sv || 0,
            cv: previous_report&.evm_cv || 0
          }
          
          # Check if all previous values are zero (except BAC which can be zero but still valid)
          all_previous_zero = previous_report.nil? || 
                             (previous_data[:pv] == 0 && 
                              previous_data[:ev] == 0 && 
                              previous_data[:ac] == 0 && 
                              previous_data[:sv] == 0 && 
                              previous_data[:cv] == 0)
          
          @reports_data << {
            project: project,
            current_report: latest_report,
            previous_report: previous_report,
            evm_setting: evm_setting,
            status_date: latest_report.status_date,
            previous_status_date: previous_report&.status_date,
            current_data: {
              bac: latest_report.evm_bac,
              pv: latest_report.evm_pv,
              ev: latest_report.evm_ev,
              ac: latest_report.evm_ac,
              sv: latest_report.evm_sv,
              cv: latest_report.evm_cv
            },
            previous_data: previous_data,
            all_previous_zero: all_previous_zero,
            differences: calculate_differences(latest_report, previous_report, evm_setting),
            note: latest_report.report_text
          }
        end
      rescue => e
        Rails.logger.error "Error getting report for project #{project.name}: #{e.message}"
        next
      end
    end
    
    respond_to do |format|
      format.html
      format.csv { send_data generate_csv, filename: "evm_reports_#{@selected_week_start.strftime('%Y%m%d')}.csv" }
    end
  end
  
  private
  
  def require_evm_reports_access
    unless User.current.admin? || can_access_evm_reports_summary?
      render_403
      return false
    end
  end
  
  def can_access_evm_reports_summary?
    return true if User.current.admin?
    
    user_roles = User.current.roles_for_project(Project.new)
    user_roles.any? { |role| EvmRolePermission.can_access_reports_summary?(role.id) }
  end
  
  def set_filters
    # Filter for week
    @selected_week = params[:week].present? ? params[:week] : "#{Date.current.year}-W#{Date.current.cweek.to_s.rjust(2, '0')}"
    year = @selected_week.split('-W')[0].to_i
    week = @selected_week.split('-W')[1].to_i
    @selected_week_start = Date.commercial(year, week, 1)
    @selected_week_end = @selected_week_start + 6.days
    
    # Filter for project status - using Project constants
    @project_status = params[:status].present? ? params[:status].to_i : nil
    
    # Generate list of weeks for dropdown
    @available_weeks = generate_available_weeks
    
    # Generate status options list
    @status_options = [
      ['', ''],  # All
      [l(:project_status_active), Project::STATUS_ACTIVE],
      [l(:project_status_closed), Project::STATUS_CLOSED],
      [l(:project_status_archived), Project::STATUS_ARCHIVED]
    ]
  end
  
  def get_latest_report_in_week(project)
    ProjectEvmreport.where(project_id: project.id)
                   .where(status_date: @selected_week_start..@selected_week_end)
                   .order(status_date: :desc, created_on: :desc)
                   .first
  end
  
  def get_previous_report(project, current_report)
    ProjectEvmreport.where(project_id: project.id)
                   .where("status_date < ?", current_report.status_date)
                   .order(status_date: :desc, created_on: :desc)
                   .first
  end
  
  def calculate_differences(current_report, previous_report, evm_setting)
    return {} unless previous_report && evm_setting
    
    {
      status_date: evm_report_status_date_difference(current_report.status_date,
                                                    previous_report.status_date,
                                                    evm_setting.exclude_holidays,
                                                    evm_setting.region),
      bac: evm_report_difference(current_report.evm_bac, previous_report.evm_bac),
      pv: evm_report_difference(current_report.evm_pv, previous_report.evm_pv),
      ev: evm_report_difference(current_report.evm_ev, previous_report.evm_ev),
      ac: evm_report_difference(current_report.evm_ac, previous_report.evm_ac),
      sv: evm_report_difference(current_report.evm_sv, previous_report.evm_sv),
      cv: evm_report_difference(current_report.evm_cv, previous_report.evm_cv)
    }
  rescue => e
    Rails.logger.error "Error calculating differences: #{e.message}"
    {}
  end
  

  
  def generate_available_weeks
    # Generate list of 52 recent weeks
    weeks = []
    current_date = Date.current
    52.times do |i|
      week_start = current_date.beginning_of_week(:monday) - (i * 7).days
      week_number = "#{week_start.year}-W#{week_start.cweek.to_s.rjust(2, '0')}"
      weeks << {
        value: week_number,
        label: "#{week_start.strftime('%d/%m/%Y')} - #{(week_start + 6.days).strftime('%d/%m/%Y')}"
      }
    end
    weeks
  end
  
  def generate_csv
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << [
        'Tên dự án',
        'Loại report',
        'Status date',
        'BAC',
        'PV',
        'EV',
        'AC',
        'SV',
        'CV',
        'Note'
      ]
      
      @reports_data.each do |data|
        # Previous Report EVM
        csv << [
          data[:project].name,
          l(:label_report_evm_previous),
          data[:all_previous_zero] ? '-' : data[:previous_status_date]&.strftime('%d/%m/%Y'),
          data[:all_previous_zero] ? '-' : data[:previous_data][:bac],
          data[:all_previous_zero] ? '-' : data[:previous_data][:pv],
          data[:all_previous_zero] ? '-' : data[:previous_data][:ev],
          data[:all_previous_zero] ? '-' : data[:previous_data][:ac],
          data[:all_previous_zero] ? '-' : data[:previous_data][:sv],
          data[:all_previous_zero] ? '-' : data[:previous_data][:cv],
          ''
        ]
        
        # Current Report EVM
        csv << [
          '',
          l(:label_report_evm_report),
          data[:status_date]&.strftime('%d/%m/%Y'),
          data[:current_data][:bac],
          data[:current_data][:pv],
          data[:current_data][:ev],
          data[:current_data][:ac],
          data[:current_data][:sv],
          data[:current_data][:cv],
          data[:note]
        ]
        
        # Changes Between Reports
        csv << [
          '',
          l(:label_report_evm_difference),
          data[:differences][:status_date],
          data[:differences][:bac],
          data[:differences][:pv],
          data[:differences][:ev],
          data[:differences][:ac],
          data[:differences][:sv],
          data[:differences][:cv],
          ''
        ]
        
        # Empty row for separation
        csv << ['', '', '', '', '', '', '', '', '', '']
      end
    end
  end
end
