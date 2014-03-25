Chakra::Engine.routes.draw do
  get "/blog" => "chakra#blog"
  get "/blog/:blogpost" => "chakra#blogpost"
  get "/projects" => "chakra#projects"
  get "/about" => "chakra#about"
  get "/events" => "chakra#events"
  get "/" => "chakra#onepage"
  get "/project/:project" => "chakra#project"
  get "/not/onepage" => "chakra#not_onepage"
  #get "posts" => "topics#index"
  #get "about" => "blog#about"
  #get "*path" => "topics#permalink"
end