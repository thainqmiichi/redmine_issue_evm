class EvmSettingsController < ApplicationController
  helper EvmSettingsHelper
  
  before_action :require_admin
  before_action :set_roles
  
  def index
    @evm_permissions = EvmRolePermission.all_permissions
    @roles_without_permissions = Role.where.not(id: @evm_permissions.pluck(:role_id))
  end
  
  def update_permissions
    if params[:permissions].present?
      params[:permissions].each do |role_id, permissions|
        EvmRolePermission.set_permission(role_id.to_i, {
          can_access_admin_dashboard: permissions[:can_access_admin_dashboard] == '1',
          can_access_reports_summary: permissions[:can_access_reports_summary] == '1'
        })
      end
      
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = l(:error_no_permissions_selected)
    end
    
    redirect_to evm_settings_path
  end
  
  def create_permission
    role_id = params[:role_id]
    
    if role_id.present?
      EvmRolePermission.set_permission(role_id.to_i, {
        can_access_admin_dashboard: true,
        can_access_reports_summary: true
      })
      flash[:notice] = l(:notice_permission_created)
    else
      flash[:error] = l(:error_role_not_selected)
    end
    
    redirect_to evm_settings_path
  end
  
  def delete_permission
    permission = EvmRolePermission.find(params[:id])
    role_name = permission.role.name
    permission.destroy
    
    flash[:notice] = l(:notice_permission_deleted, role: role_name)
    redirect_to evm_settings_path
  rescue ActiveRecord::RecordNotFound
    flash[:error] = l(:error_permission_not_found)
    redirect_to evm_settings_path
  end
  
  private
  
  def set_roles
    @roles = Role.order(:name)
  end
end
