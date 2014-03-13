module Splash
  class ChakraController < Splash::ApplicationController
    layout "chakra"
    def onepage
      @projects = OnepagePlugin::projects
      @categories = []
      @display_slider = true

      @events = OnepagePlugin::events
      @cities = @events.group_by{|e| e.city}.keys.compact
      render "onepage"
    end

    def blog
      @blogposts = OnepagePlugin::blogposts
      render "blog"
    end

    def project
      @project = OnepagePlugin::find_project(params[:project])
      render "project"
    end
  end
end
