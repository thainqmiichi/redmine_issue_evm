# routing
Rails.application.routes.draw do
  resources :projects do
    resources :evms, :evmbaselines, :evmsettings, :evmassignees, :evmparentissues, :evmversions, :evmtrackers, :evmexcludes,
              :evmbaselinediffdetails, :evmreports
  end
  
  # Admin EVM Dashboard routes
  get 'admin/evm_dashboard', to: 'admin_evm_dashboard#index', as: :admin_evm_dashboard
  
  # EVM Reports Summary routes
  get 'evm_reports_summary', to: 'evm_reports_summary#index', as: :evm_reports_summary
  
  # EVM Settings routes
  get 'admin/evm_settings', to: 'evm_settings#index', as: :evm_settings
  patch 'admin/evm_settings/update_permissions', to: 'evm_settings#update_permissions', as: :update_permissions_evm_settings
  post 'admin/evm_settings/create_permission', to: 'evm_settings#create_permission', as: :create_permission_evm_settings
  delete 'admin/evm_settings/:id/delete_permission', to: 'evm_settings#delete_permission', as: :delete_permission_evm_settings
end
