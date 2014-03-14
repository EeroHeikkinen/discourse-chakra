module Chakra
  class ChakraController < ActionController::Base
    layout "chakra"
    def onepage
      @projects = OnepagePlugin::projects
      @categories = []
      @display_slider = true

      @events = OnepagePlugin::events
      @cities = @events.group_by{|e| e.past ? nil : e.city}.keys.compact
      @calendar_url = SiteSetting.googlecalendar_url
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
