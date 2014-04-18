# name: chakra
# about: Chakra frontend for Discourse
# version: 0.1
# authors: Eero Heikkinen

#::BLOG_HOST = Rails.env.development? ? "dev.samsaffron.com" : "samsaffron.com"
#::BLOG_DISCOURSE = Rails.env.development? ? "l.discourse" : "discuss.samsaffron.com"

gem "google_calendar", "0.3.1"

module ::Chakra
  class Engine < ::Rails::Engine
    engine_name "chakra"
    isolate_namespace Chakra
  end
end

register_asset 'javascripts/event_route.js'
register_asset 'javascripts/project_participants.js'
register_asset 'javascripts/discourse/templates/project_participants.js.handlebars'

register_css <<CSS
.project-participants-view {
  margin-top: 5px;
}
.project-participants-view .btn {
  background-color: #000;
}
.project-participants-view .label {
  padding: 1px 7px;
  font-size: 0.8em;
}

CSS

Rails.configuration.assets.precompile += 
['chakra.js', 'chakra.css']

after_initialize do
  require_dependency File.expand_path('../integrate.rb', __FILE__)
  load File.expand_path("../metadata.rb", __FILE__)
  load File.expand_path("../events.rb", __FILE__)
  load File.expand_path("../projects.rb", __FILE__)
  load File.expand_path("../blogposts.rb", __FILE__)

  #load File.expand_path("../app/jobs/blog_update_twitter.rb", __FILE__)
  #load File.expand_path("../app/jobs/blog_update_stackoverflow.rb", __FILE__)

  Discourse::Application.routes.prepend do
    mount ::Chakra::Engine, at: "/"
    get 'create_event/:date' => 'list#category_latest', 
      defaults: { category: SiteSetting.events_category },
      :constraints => { :date => /[^\/]+/ }
    get 'create_idea' => 'list#category_latest',
      defaults: { category: SiteSetting.ideas_category }
  end

  Category.class_eval do
    def url
      if slug == SiteSetting.events_category
        return "/events"
      end
      if slug == SiteSetting.projects_category
        return "/projects"
      end
      return super
    end
  end

  # Starting a topic title with "Poll:" will create a poll topic. If the title
  # starts with "poll:" but the first post doesn't contain a list of options in
  # it we need to raise an error.
  Post.class_eval do
    validate :poll_options
    def poll_options
      poll = PollPlugin::Poll.new(self)

      return unless poll.is_poll?

      if poll.options.length == 0
        self.errors.add(:raw, I18n.t('poll.must_contain_poll_options'))
      end

      poll.ensure_can_be_edited!
    end
  end

  require_dependency "plugin/filter"

  def get_handler(post)
    if OnepagePlugin::Event.is_event?(post.topic)
      OnepagePlugin::Event.new(post.topic)
    elsif OnepagePlugin::Project.is_project?(post.topic)
      OnepagePlugin::Project.new(post.topic)
    elsif OnepagePlugin::BlogPost.is_blogpost?(post.topic)
      OnepagePlugin::BlogPost.new(post.topic)
    end
  end

  Plugin::Filter.register(:after_post_cook) do |post, cooked|
    debugger
    handler = get_handler(post)

    if(handler) 
      handler.parse_summary(cooked)
      handler.sync_metadata(cooked)
    end
    
    cooked
  end
end
