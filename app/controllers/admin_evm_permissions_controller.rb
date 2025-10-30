class AdminEvmPermissionsController < ApplicationController
  layout 'admin'
  before_action :require_admin

  def index
    @roles = Role.all
  end

  def update
    Role.update_all(can_view_evm: false)
    Role.where(id: params[:role_ids]).update_all(can_view_evm: true) if params[:role_ids].present?
    flash[:notice] = l(:notice_successful_update)
    redirect_to admin_evm_permissions_path
  end
end
