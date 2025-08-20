# routing
Rails.application.routes.draw do
  resources :projects do
    resources :evms, :evmbaselines, :evmsettings, :evmassignees, :evmparentissues, :evmversions, :evmtrackers, :evmexcludes,
              :evmbaselinediffdetails, :evmreports
  end
  
  # Admin EVM Dashboard routes
  get 'admin/evm_dashboard', to: 'admin_evm_dashboard#index', as: :admin_evm_dashboard
end
