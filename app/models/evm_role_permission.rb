class EvmRolePermission < ActiveRecord::Base
  belongs_to :role
  
  validates :role_id, presence: true, uniqueness: true
  
  # Scope để lấy quyền cho một role cụ thể
  scope :for_role, ->(role_id) { where(role_id: role_id) }
  
  # Kiểm tra quyền truy cập admin dashboard
  def self.can_access_admin_dashboard?(role_id)
    permission = find_by(role_id: role_id)
    permission&.can_access_admin_dashboard || false
  end
  
  # Kiểm tra quyền truy cập reports summary
  def self.can_access_reports_summary?(role_id)
    permission = find_by(role_id: role_id)
    permission&.can_access_reports_summary || false
  end
  
  # Tạo hoặc cập nhật quyền cho role
  def self.set_permission(role_id, permissions = {})
    permission = find_or_initialize_by(role_id: role_id)
    permission.assign_attributes(permissions)
    permission.save!
  end
  
  # Lấy tất cả quyền cho tất cả roles
  def self.all_permissions
    includes(:role).order('roles.name')
  end
end
