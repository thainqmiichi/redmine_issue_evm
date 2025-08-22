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
end
