Chakra::Engine.routes.draw do
  get "/blog" => "chakra#blog"
  get "/" => "chakra#onepage"
  get "/project/:project" => "chakra#project"
  #get "posts" => "topics#index"
  #get "about" => "blog#about"
  #get "*path" => "topics#permalink"
end