# name: blog
# about: blog frontend for Discourse
# version: 0.1
# authors: Sam Saffron

gem "multi_xml","0.5.5"
gem "httparty", "0.12.0"
gem "rubyoverflow", "1.0.2"

#::BLOG_HOST = Rails.env.development? ? "dev.samsaffron.com" : "samsaffron.com"
#::BLOG_DISCOURSE = Rails.env.development? ? "l.discourse" : "discuss.samsaffron.com"


module ::Splash
  class Engine < ::Rails::Engine
    engine_name "splash"
    isolate_namespace Splash
  end
end


Rails.configuration.assets.precompile += ['LAB.js', 'blog.css']

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

      def sync_metadata(cooked)
        properties = options(cooked)
        return unless properties
        properties.each{|key, value| add_meta_data(key, value)}
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
    mount ::Splash::Engine, at: "/"
  end

  require_dependency "plugin/filter"

  Plugin::Filter.register(:after_post_cook) do |post, cooked|
    debugger
    event = OnepagePlugin::Event.new(post.topic)
    if event.is_event?
      event.parse_summary(cooked)
    else
      project = OnepagePlugin::Project.new(post.topic)
      if project.is_project?
        project.parse_summary(cooked)
        project.sync_metadata(cooked)
      else
        blogpost = OnepagePlugin::BlogPost.new(post.topic)
        if blogpost.is_blogpost?
          blogpost.parse_summary(cooked)
          blogpost.sync_metadata(cooked)
        end
      end
    end
    
    cooked
  end
end
