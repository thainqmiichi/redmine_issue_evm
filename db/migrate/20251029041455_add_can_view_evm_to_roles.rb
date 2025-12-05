class AddCanViewEvmToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :can_view_evm, :boolean
  end
end
