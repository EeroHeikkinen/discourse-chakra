require_dependency 'discourse'
require_dependency 'archetype'

module Splash
  class ApplicationController < ActionController::Base
    include CurrentUser
    layout "2col"
    before_filter :cache_anon

    def cache_anon
      Middleware::AnonymousCache.anon_cache(request.env, 30.seconds)
    end

    def show_sidebar
      true
    end
  end
end
