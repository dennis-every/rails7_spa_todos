Rails.application.routes.draw do
  resources :todos
  resources :posts
  root "todos#index"
end
