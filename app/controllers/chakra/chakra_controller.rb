require 'current_user'
require_dependency 'discourse'

module Chakra
  class ChakraController < ActionController::Base
    include CurrentUser
    layout "chakra"
    def onepage
      if(current_user)
        @loggedIn = true
      end
      @projects = OnepagePlugin::projects
      @categories = []
      @display_slider = true

      @events = OnepagePlugin::events
      @cities = @events.group_by{|e| e.past ? nil : e.city}.keys.compact
      @calendar_url = SiteSetting.googlecalendar_url
      render "onepage"
    end

    def not_onepage
      @not_onepage = true
      @display_slider = true
    end

    def projects
      @not_onepage = true
      @projects = OnepagePlugin::projects
      @categories = []
      render "projects"
    end

    def events
      if(current_user)
        @loggedIn = true
      end
      @not_onepage = true
      @events = OnepagePlugin::events
      @cities = @events.group_by{|e| e.past ? nil : e.city}.keys.compact
      @calendar_url = SiteSetting.googlecalendar_url
      render "events"
    end

    def about
      @not_onepage = true
      render "about"
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
