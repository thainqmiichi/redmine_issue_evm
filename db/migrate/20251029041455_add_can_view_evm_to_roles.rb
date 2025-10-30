class AddCanViewEvmToRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :roles, :can_view_evm, :boolean
  end
end
