require File.expand_path('../../test_helper', __FILE__)

class EvmRolePermissionTest < ActiveSupport::TestCase
  fixtures :roles, :users, :projects, :members, :member_roles

  def setup
    @role = roles(:roles_001) # Manager role
    @admin_role = roles(:roles_001) # Assuming this is admin role
    @user = users(:users_001)
    @project = projects(:projects_001)
  end

  def test_create_permission
    permission = EvmRolePermission.create!(
      role_id: @role.id,
      can_access_admin_dashboard: true,
      can_access_reports_summary: false
    )
    
    assert permission.persisted?
    assert permission.can_access_admin_dashboard
    assert_not permission.can_access_reports_summary
  end

  def test_unique_role_constraint
    # Create first permission
    EvmRolePermission.create!(role_id: @role.id)
    
    # Try to create second permission for same role
    assert_raises(ActiveRecord::RecordNotUnique) do
      EvmRolePermission.create!(role_id: @role.id)
    end
  end

  def test_can_access_admin_dashboard_method
    # Test when permission exists and is true
    EvmRolePermission.create!(
      role_id: @role.id,
      can_access_admin_dashboard: true
    )
    assert EvmRolePermission.can_access_admin_dashboard?(@role.id)
    
    # Test when permission exists and is false
    EvmRolePermission.where(role_id: @role.id).update_all(can_access_admin_dashboard: false)
    assert_not EvmRolePermission.can_access_admin_dashboard?(@role.id)
    
    # Test when permission doesn't exist
    EvmRolePermission.where(role_id: @role.id).destroy_all
    assert_not EvmRolePermission.can_access_admin_dashboard?(@role.id)
  end

  def test_can_access_reports_summary_method
    # Test when permission exists and is true
    EvmRolePermission.create!(
      role_id: @role.id,
      can_access_reports_summary: true
    )
    assert EvmRolePermission.can_access_reports_summary?(@role.id)
    
    # Test when permission exists and is false
    EvmRolePermission.where(role_id: @role.id).update_all(can_access_reports_summary: false)
    assert_not EvmRolePermission.can_access_reports_summary?(@role.id)
    
    # Test when permission doesn't exist
    EvmRolePermission.where(role_id: @role.id).destroy_all
    assert_not EvmRolePermission.can_access_reports_summary?(@role.id)
  end

  def test_set_permission_method
    # Test creating new permission
    EvmRolePermission.set_permission(@role.id, {
      can_access_admin_dashboard: true,
      can_access_reports_summary: false
    })
    
    permission = EvmRolePermission.find_by(role_id: @role.id)
    assert permission
    assert permission.can_access_admin_dashboard
    assert_not permission.can_access_reports_summary
    
    # Test updating existing permission
    EvmRolePermission.set_permission(@role.id, {
      can_access_admin_dashboard: false,
      can_access_reports_summary: true
    })
    
    permission.reload
    assert_not permission.can_access_admin_dashboard
    assert permission.can_access_reports_summary
  end

  def test_all_permissions_method
    # Create permissions for multiple roles
    role2 = roles(:roles_002)
    EvmRolePermission.create!(role_id: @role.id, can_access_admin_dashboard: true)
    EvmRolePermission.create!(role_id: role2.id, can_access_reports_summary: true)
    
    permissions = EvmRolePermission.all_permissions
    assert_equal 2, permissions.count
    assert permissions.any? { |p| p.role_id == @role.id }
    assert permissions.any? { |p| p.role_id == role2.id }
  end

  def test_belongs_to_role
    permission = EvmRolePermission.create!(role_id: @role.id)
    assert_equal @role, permission.role
  end

  def test_validation_requires_role_id
    permission = EvmRolePermission.new
    assert_not permission.valid?
    assert_includes permission.errors[:role_id], "can't be blank"
  end
end
