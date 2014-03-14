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

Rails.configuration.assets.precompile += 
['chakra.js', 'chakra.css']

after_initialize do

  module ::OnepagePlugin
    class Metadata
      def initialize(topic)
        @topic = topic
        @post = topic.posts.first
      end

      def meta_data(key)
        return unless @topic.meta_data
        @topic.meta_data[key]
      end

      def add_meta_data(key,value)
        @topic.update_attribute('meta_data', (@topic.meta_data || {}).merge(key => value))
      end

      # Read event options from post
      def options(cooked)
        cooked = PrettyText.cook(@post.raw, topic_id: @post.topic_id) unless cooked
        parsed = Nokogiri::HTML(cooked)
        options_list = parsed.css("ul").first
        return unless options_list

        read_properties = {}
        options_list.css("li").each do |i|
          text = i.children.to_s.strip
          properties.each do |key|
            prefix = prefixes[key]
            if text.start_with?(prefix)
              read_properties[key] = text.sub(prefix, '').strip
              break
            end
          end
        end

        read_properties
      end

      def parse_summary(cooked)
        split = cooked.gsub("<hr/>", "<hr>").split("<hr>")

        if split.length > 1
          summary = Nokogiri::HTML.fragment(split[0]).content.strip
          add_meta_data("summary", summary)
          cooked = split[1..-1].join("<hr>")
        end
      end

      def title
        @topic.title
      end

      def id 
        @topic.id
      end

      def url
        Topic::url(@topic.id, @topic.slug)
      end

      def summary
        meta_data("summary")
      end

      def image_url
        @topic.image_url
      end
    end
  end

  load File.expand_path("../events.rb", __FILE__)
  load File.expand_path("../projects.rb", __FILE__)
  load File.expand_path("../blogposts.rb", __FILE__)

  #load File.expand_path("../app/jobs/blog_update_twitter.rb", __FILE__)
  #load File.expand_path("../app/jobs/blog_update_stackoverflow.rb", __FILE__)

  Discourse::Application.routes.prepend do
    mount ::Chakra::Engine, at: "/"
  end

  require_dependency "plugin/filter"

  Plugin::Filter.register(:after_post_cook) do |post, cooked|
    debugger
    if OnepagePlugin::Event.is_event?(post.topic)
      handler = OnepagePlugin::Event.new(post.topic)
    elsif OnepagePlugin::Project.is_project?(post.topic)
      handler = OnepagePlugin::Project.new(post.topic)
    elsif OnepagePlugin::BlogPost.is_blogpost?(post.topic)
      handler = OnepagePlugin::BlogPost.new(post.topic)
    end

    return unless handler

    handler.parse_summary(cooked)
    handler.sync_metadata(cooked)
    
    cooked
  end
end
