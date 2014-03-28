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
      @ideas = ideas
      @categories = []
      @display_slider = true

      @events = OnepagePlugin::events
      @cities = cities
      @calendar_url = SiteSetting.googlecalendar_url
      render "onepage"
    end

    def not_onepage
      @not_onepage = true
      @display_slider = true
    end

    def ideas 
      ideas_category_id = Category.query_parent_category(SiteSetting.ideas_category);
      return unless ideas_category_id

      Topic.visible.listable_topics
        .joins(:category)
        .where("(categories.parent_category_id = ? " +
        " OR categories.id = ?)" +
        " AND topics.pinned_at IS NULL", 
        ideas_category_id, ideas_category_id)
    end

    def projects
      @not_onepage = true
      @projects = OnepagePlugin::projects
      @ideas = ideas
      @categories = []
      render "projects"
    end

    def events
      if(current_user)
        @loggedIn = true
      end
      @not_onepage = true
      @events = OnepagePlugin::events
      @cities = cities
      @calendar_url = SiteSetting.googlecalendar_url
      if params[:narrow]
        @narrow = true
      end
      render "events"
    end

    def about
      @not_onepage = true
      @showteam = false
      render "about"
    end

    def blog
      @blogposts = OnepagePlugin::blogposts
      render "blog"
    end

    def blogpost
      @blogpost = OnepagePlugin::find_blogpost(params[:blogpost])
      render "blogpost"
    end

    def project
      @project = OnepagePlugin::find_project(params[:project])
      render "project"
    end

    private 
    def cities
      @events.group_by{|e| e.when == 'past' ? nil : e.city}.keys.compact
    end
  end
end
