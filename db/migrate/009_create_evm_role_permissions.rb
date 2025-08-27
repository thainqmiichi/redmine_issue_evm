class CreateEvmRolePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :evm_role_permissions do |t|
      t.integer :role_id, null: false
      t.boolean :can_access_admin_dashboard, default: false
      t.boolean :can_access_reports_summary, default: false
      t.timestamps
    end
    
    add_index :evm_role_permissions, :role_id, unique: true
    add_foreign_key :evm_role_permissions, :roles, on_delete: :cascade
  end
end
