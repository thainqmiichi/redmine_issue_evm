class AddCanViewEvmToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :can_view_evm, :boolean
  end
end
