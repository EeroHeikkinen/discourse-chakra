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
        all_lists = parsed.css("ul")
        return unless all_lists

        read_properties = {}
        all_lists.css("li").each do |i|
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

      def cooked 
        @post.cooked
      end

      def posts
        @topic.posts
      end

      def posts_count
        @topic.posts_count
      end

      def id 
        @topic.id
      end

      def category
        @topic.category
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