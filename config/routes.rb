Wtools::Application.routes.draw do
  resources :messages do
		post 'read', :on => :member
	end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  devise_for :users do
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
    get "register", :to => "devise/registrations#new"
  end

  resources :user_logs
  resources :replies
  resources :styles do
    collection do
      get :check
      get :get_setting
    end
  end

  resources :feedbacks do
    collection do
      post :vote
    end
  end
	resources :job_feedbacks, :controller => 'feedbacks'
	resources :plan_feedbacks, :controller => 'feedbacks'

  resources :questions
	resources :job_questions, :controller => 'questions'
	resources :plan_questions, :controller => 'questions'
	
  resources :plans, :controller => 'tasks', :type => 'plan'
  resources :jobs, :controller => 'tasks', :type => 'job'
  match '/plans/new(/:step(/:task_id))' => 'tasks#new', :as => :plan_new, :type => 'plan'
  match '/jobs/new(/:step(/:task_id))' => 'tasks#new', :as => :job_new, :type => 'job'
	match '/tasks/new(/:step(/:task_id))' => 'tasks#new'
  resources :tasks
  resources :task_logs do
    collection do
      post :save_log
    end
  end

  resources :websites
  match '/home' => 'users#show', :as => :user_root

	# /alice/tasks/1.png
  # /alice/tasks.png
	match '/show/:username/:type(/:id)(.:format)' => "site#task_show", :as => :task_show

  match '/utilities/:action', :controller => 'utilities'

  # /utilities/task_chart/1/line.png
  match '/utilities/task_chart/:id/:type(.:format)' => "utilities#task_chart", :as => :task_chart

	#match '/:action', :controller => 'site'
	match '/invite(/:user_id)' => 'site#invite'
	
	match ':controller(/:action(/:id(.:format)))'
	match '/:action', :controller => 'site'
  root :to => 'site#index'
end
