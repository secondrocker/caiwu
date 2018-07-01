Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :sales
  root to: 'sales#index'
  resources :team_sets,only:[:index,:create,:update,:destroy] do
    post :clone_team_set
    get  :team_sales
  end
  delete '/team_sets/:id/delete_team',to:'team_sets#delete_team',as:'delete_team'
  post '/team_sets/:team_set_id/create_team',to:'team_sets#create_team',as:'create_team'
  post '/team_sets/:id/show_edit_team_sales',to:'team_sets#show_edit_team_sales',as:'show_edit_team_sales'
  post '/team_sets/save_team_sales',to:'team_sets#save_team_sales'

  resources :report_settings,only:[:index]
  post '/report_settings/save_report_setting',to:'report_settings#save_report_setting' ,as:'save_report_setting'
  post '/report_settings/new_leader_requirment',to:'report_settings#new_leader_requirment',as:'new_leader_requirment'
  post '/report_settings/copy_last_month_set/:year_and_month',to:'report_settings#copy_last_month_set',as:'copy_last_month_set'

  resources :subscriptions
  post '/subscriptions/:id/generate_order',to:'subscriptions#generate_order',as:'generate_order'
  resources :orders
  patch '/orders/:id/save_order_payments',to:'orders#save_order_payments',as:'save_order_payments'

  get '/sales_reports/sub_report',to:'sales_reports#sub_report',as:'sub_report'
  get '/sales_reports/:report_id/sub_report_detail/:sale_id',to:'sales_reports#sub_report_detail',as:'sub_report_detail'

  get '/sales_reports/sub_price_report',to:'sales_reports#sub_price_report',as:'sub_price_report'
  get '/sales_reports/:report_id/sub_price_report_detail/:sale_id',to:'sales_reports#sub_price_report_detail',as:'sub_price_report_detail'

  get '/sales_reports/sale_pay_report',to:'sales_reports#sale_pay_report',as:'sale_pay_report'
  get '/sales_reports/:report_id/sale_pay_report_detail/:sale_id',to:'sales_reports#sale_pay_report_detail',as:'sale_pay_report_detail'

  get '/sales_reports/leader_pay_report',to:'sales_reports#leader_pay_report',as:'leader_pay_report'
  get '/sales_reports/:report_id/leader_pay_report_detail/:sale_id',to:'sales_reports#leader_pay_report_detail',as:'leader_pay_report_detail'

  get '/sales_reports/manager_pay_report',to:'sales_reports#manager_pay_report',as:'manager_pay_report'
  get '/sales_reports/:report_id/manager_pay_report_detail/:sale_id',to:'sales_reports#manager_pay_report_detail',as:'manager_pay_report_detail'

  get '/sales_reports/director_pay_report',to:'sales_reports#director_pay_report',as:'director_pay_report'
  get '/sales_reports/:report_id/director_pay_report_detail/:sale_id',to:'sales_reports#director_pay_report_detail',as:'director_pay_report_detail'
end
