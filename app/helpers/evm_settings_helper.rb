module EvmSettingsHelper
  def evm_permission_checkbox(form, permission_name, label)
    content_tag(:div, class: 'permission-checkbox') do
      form.check_box(permission_name) + 
      form.label(permission_name, label, class: 'inline')
    end
  end
  
  def role_permission_status(role)
    permission = EvmRolePermission.find_by(role_id: role.id)
    if permission
      content_tag(:span, l(:label_configured), class: 'status configured')
    else
      content_tag(:span, l(:label_not_configured), class: 'status not-configured')
    end
  end
  
  def permission_summary(permission)
    permissions = []
    permissions << l(:label_admin_dashboard) if permission.can_access_admin_dashboard
    permissions << l(:label_reports_summary) if permission.can_access_reports_summary
    
    if permissions.any?
      permissions.join(', ')
    else
      l(:label_no_permissions)
    end
  end
end
