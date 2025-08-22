# EVM Reports Summary Helper
module EvmReportsSummaryHelper
  include Redmine::Export::PDF
  
  # Format EVM value
  def format_evm_value(value)
    return '-' if value.nil?
    number_with_precision(value, precision: 2)
  end
  
  # Format EVM value for previous report (show "-" if all values are 0.00)
  def format_previous_evm_value(value, all_previous_values_zero = false)
    return '-' if value.nil? || all_previous_values_zero
    number_with_precision(value, precision: 2)
  end
  
  # Get CSS class for EVM value
  def evm_value_class(value)
    return 'neutral' if value.nil?
    
    if value > 0
      'positive'
    elsif value < 0
      'negative'
    else
      'neutral'
    end
  end
  
  # Get project status label
  def project_status_label(status)
    case status
    when Project::STATUS_ACTIVE
      l(:label_open)
    when Project::STATUS_CLOSED
      l(:label_closed)
    when Project::STATUS_ARCHIVED
      l(:label_archived)
    else
      l(:label_unknown)
    end
  end
  
  # Get report type label
  def report_type_label(report_type)
    case report_type
    when 'EVM on status date'
      l(:label_evm_on_status_date)
    when 'Previously reported EVM'
      l(:label_previously_reported_evm)
    when 'Previously reported EVM differences'
      l(:label_previously_reported_evm_differences)
    else
      report_type
    end
  end
end
