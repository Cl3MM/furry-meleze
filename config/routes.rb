Meleze::Application.routes.draw do

  resources :searches

  resources :destinations

  get 'destinations/find_by_nomenclature/:nomenclature', to: 'destinations#find_by_nomenclature', as: :find_by_nomenclature, format: [:js, :json]

  get  "attachments", to: "attachments#index"
  get  'attachments/:id', to: 'attachments#show', as: :attachment
  get  "dashboard", to: "dashboard#index"

  devise_for :utilisateurs, :path => '', :path_names => {:sign_in => 'connexion', :sign_out => 'deconnexion'}

  post 'immatriculation/:id', to: 'immatriculation#create', as: :create_immatriculation
  get  'ebsdds/:status', to: 'ebsdds#index', as: :ebsdd_status, constraints: EbsddStatus
  get  'ebsdds/printpdf/:id', to: 'ebsdds#print_pdf', defaults: { format: :pdf }, as: :ebsdd_printpdf
  get  'ebsdds/download/:id', to: 'ebsdds#download', defaults: { format: :csv }, as: :ebsdd_download
  get  'ebsdds/annexe/:id', to: 'ebsdds#annexe_export', defaults: { format: :csv }, as: :ebsdd_annexe
  #get  'ebsdds/reset', to: 'ebsdds#reset', as: :reset
  get  'ebsdds/search_form', to: 'ebsdds#search_form', as: :ebsdds_search_form
  get  'ebsdds/search/:q', to: 'ebsdds#search', as: :ebsdds_search
  get  'ebsdds/import'
  post 'ebsdds/upload'
  match  'ebsdds/selection', to: 'ebsdds#selection', as: :ebsdds_selection, via: [:get, :post]
  post  'ebsdds/export', to: 'ebsdds#export', as: :ebsdds_export

  #post  '/search', to: "producteurs#search", as: :producteurs_search

  post 'destinataires/search', to: "companies#search", as: :destinataires_search
  post 'producteurs/search', to: "producteurs#search", as: :producteurs_search
  get  'producteurs/import'
  post 'producteurs/upload'

  #get 'destinataires/import'
  #post 'destinataires/upload'

  resources :collecteurs #, controller: :companies, type: "Destinateire"
  resources :destinataires #, controller: :companies, type: "Destinateire"

  resources :ebsdds
  resources :producteurs

  root to: 'dashboard#index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products'

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
