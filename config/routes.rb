Meleze::Application.routes.draw do

  resources :searches

  resources :destinations
  resources :utilisateurs

  get 'destinations/find_by_nomenclature/:nomenclature', to: 'destinations#find_by_nomenclature', as: :find_by_nomenclature, format: [:js, :json]

  get  "attachments", to: "attachments#index"
  get  'attachments/:id', to: 'attachments#show', as: :attachment
  get  "dashboard", to: "dashboard#index"
  get  "statistiques", to: "statistiques#index"
  post "statistiques/camions", to: "statistiques#camions"
  post "statistiques/destinations", to: "statistiques#destinations"
  post "statistiques/quantites", to: "statistiques#quantites"
  get  "statistiques/quantites_to_csv", to: "statistiques#quantites_to_csv", default: {format: :csv}
  get  "statistiques/camions_to_csv", to: "statistiques#camions_to_csv", default: {format: :csv}
  get  "statistiques/destinations_to_csv", to: "statistiques#destinations_to_csv", default: {format: :csv}

  devise_for :utilisateurs, :path => '', :path_names => {:sign_in => 'connexion', :sign_out => 'deconnexion'}

  post 'immatriculation/:id', to: 'immatriculation#create', as: :create_immatriculation
  get  'ebsdds/:status', to: 'ebsdds#index', as: :ebsdd_status, constraints: EbsddStatus
  get  'ebsdds/printpdf/:id', to: 'ebsdds#print_pdf', defaults: { format: :pdf }, as: :ebsdd_printpdf
  get  'searches/:id/gestion_matiere', to: 'searches#gestion_matiere', defaults: { format: :csv }, as: :gestion_matiere
  get  'ebsdds/download/:id', to: 'ebsdds#download', defaults: { format: :csv }, as: :ebsdd_download
  get  'ebsdds/annexe/:id', to: 'ebsdds#annexe_export', defaults: { format: :csv }, as: :ebsdd_annexe
  #get  'ebsdds/reset', to: 'ebsdds#reset', as: :reset
  get  'ebsdds/search_form', to: 'ebsdds#search_form', as: :ebsdds_search_form
  get  'ebsdds/search/:q', to: 'ebsdds#search', as: :ebsdds_search
  get  'ebsdds/import'
  post 'ebsdds/upload'
  match 'ebsdds/selection', to: 'ebsdds#selection', as: :ebsdds_selection, via: [:get, :post]
  post 'ebsdds/export', to: 'ebsdds#export', as: :ebsdds_export
  post 'ebsdds/nouveaux_pdfs', to: 'ebsdds#nouveaux_pdfs', as: :ebsdds_nouveaux_pdfs
  post 'ebsdds/change_nouveau_statut', to: 'ebsdds#change_nouveau_statut'
  post 'ebsdds/change_en_attente_statut', to: 'ebsdds#change_en_attente_statut'
  put 'ebsdds/:id/split', to: 'ebsdds#split'
  post 'ebsdd/:id/change_nouveau_statut', to: 'ebsdds#change_ebsdd_nouveau_statut'
  post 'ebsdd/:id/change_en_attente_statut', to: 'ebsdds#change_ebsdd_en_attente_statut'

  post  'ebsdds/types_dechet_a_sortir', to: 'ebsdds#types_dechet_a_sortir', as: :ebsdds_type_dechet_a_sortir
  post  'ebsdds/a_sortir', to: 'ebsdds#a_sortir', as: :ebsdds_a_sortir
  # Bons de sortie
  get  'bon_de_sorties/new', to: 'bon_de_sorties#new', as: :new_bon_de_sortie
  post 'bon_de_sorties', to: 'bon_de_sorties#create'
  get 'bon_de_sorties/:id', to: 'bon_de_sorties#show', as: :bon_de_sortie
  get 'bon_de_sorties', to: 'bon_de_sorties#index', as: :bon_de_sorties
  post 'bon_de_sorties/search', to: "bon_de_sorties#search", as: :bon_de_sorties_search

  get  'bon_de_sorties/printpdf/:id', to: "bon_de_sorties#prout", defaults: { format: :pdf }, as: :bon_de_sortie_pdf
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
  resources :produits
  post 'produits/search', to: 'produits#search', as: :produits_search

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
