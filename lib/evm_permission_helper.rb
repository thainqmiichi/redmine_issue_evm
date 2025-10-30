module EvmPermissionHelper
  def can_view_evm?(user = User.current)
    return false unless user&.logged?
    return true if user.admin?
    role_ids = user.memberships.map(&:roles).flatten.map(&:id).uniq
    Role.where(id: role_ids, can_view_evm: true).exists?
  end

  def evm_viewable_projects(base_scope = Project.visible.active, user = User.current)
    return Project.none unless user&.logged?
    return base_scope.order(:name).distinct if user.admin?

    base_scope
      .joins("INNER JOIN members ON members.project_id = projects.id")
      .joins("INNER JOIN member_roles ON member_roles.member_id = members.id")
      .joins("INNER JOIN roles ON roles.id = member_roles.role_id")
      .where("members.user_id = ? AND roles.can_view_evm = ?", user.id, true)
      .distinct
      .order(:name)
  end
end
