Tailf::Engine.routes.draw do
  mount_tailf
  # get "log/index"
  # resource :users
	# get "tailf" => "tailf/application#index"
	# mount Tailf::Engine => "/tailf", :as => "tailf_engine"
end
# Rails.application.config.middleware.swap Rails::Rack::Logger, CustomLogger, :silenced => ["/application/log"]	