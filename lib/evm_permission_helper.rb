module EvmPermissionHelper
  def can_view_evm?(user = User.current)
    return false unless user&.logged?
    return true if user.admin?
    role_ids = user.memberships.map(&:roles).flatten.map(&:id).uniq
    Role.where(id: role_ids, can_view_evm: true).exists?
  end
end
