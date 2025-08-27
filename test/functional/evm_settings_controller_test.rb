require File.expand_path('../../test_helper', __FILE__)

class EvmSettingsControllerTest < ActionController::TestCase
  fixtures :roles, :users, :projects, :members, :member_roles

  def setup
    @admin_user = users(:users_001) # Assuming this is admin
    @normal_user = users(:users_002)
    @role = roles(:roles_001)
    
    # Make sure admin user is actually admin
    @admin_user.update!(admin: true)
  end

  def test_index_requires_admin
    # Test non-admin user
    @request.session[:user_id] = @normal_user.id
    get :index
    assert_response :forbidden
    
    # Test admin user
    @request.session[:user_id] = @admin_user.id
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_index_displays_roles
    @request.session[:user_id] = @admin_user.id
    get :index
    
    assert_response :success
    assert_not_nil assigns(:roles)
    assert_not_nil assigns(:evm_permissions)
    assert_not_nil assigns(:roles_without_permissions)
  end

  def test_update_permissions
    @request.session[:user_id] = @admin_user.id
    
    # Create a permission first
    permission = EvmRolePermission.create!(role_id: @role.id)
    
    patch :update_permissions, params: {
      permissions: {
        @role.id.to_s => {
          can_access_admin_dashboard: '1',
          can_access_reports_summary: '0'
        }
      }
    }
    
    assert_redirected_to evm_settings_path
    assert_equal 'Settings were successfully updated.', flash[:notice]
    
    permission.reload
    assert permission.can_access_admin_dashboard
    assert_not permission.can_access_reports_summary
  end

  def test_update_permissions_with_no_permissions
    @request.session[:user_id] = @admin_user.id
    
    patch :update_permissions, params: {}
    
    assert_redirected_to evm_settings_path
    assert_equal 'No permissions were selected.', flash[:error]
  end

  def test_create_permission
    @request.session[:user_id] = @admin_user.id
    
    post :create_permission, params: { role_id: @role.id }
    
    assert_redirected_to evm_settings_path
    assert_equal 'Role permission was successfully created.', flash[:notice]
    
    permission = EvmRolePermission.find_by(role_id: @role.id)
    assert permission
    assert_not permission.can_access_admin_dashboard
    assert_not permission.can_access_reports_summary
  end

  def test_create_permission_without_role_id
    @request.session[:user_id] = @admin_user.id
    
    post :create_permission, params: {}
    
    assert_redirected_to evm_settings_path
    assert_equal 'Please select a role.', flash[:error]
  end

  def test_delete_permission
    @request.session[:user_id] = @admin_user.id
    
    permission = EvmRolePermission.create!(role_id: @role.id)
    
    delete :delete_permission, params: { id: permission.id }
    
    assert_redirected_to evm_settings_path
    assert_equal "Role permission for \"#{@role.name}\" was successfully deleted.", flash[:notice]
    
    assert_nil EvmRolePermission.find_by(id: permission.id)
  end

  def test_delete_permission_not_found
    @request.session[:user_id] = @admin_user.id
    
    delete :delete_permission, params: { id: 99999 }
    
    assert_redirected_to evm_settings_path
    assert_equal 'Permission not found.', flash[:error]
  end

  def test_set_roles_method
    @request.session[:user_id] = @admin_user.id
    get :index
    
    assert_not_nil assigns(:roles)
    assert assigns(:roles).any?
  end
end
