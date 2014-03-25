module ::OnepagePlugin
  def self.list_blogposts
    t = Topic.secured.visible.listable_topics
      .joins(:category)
      .where("(categories.slug = '" + SiteSetting.blog_category + "'" +
      " AND topics.pinned_at IS NULL)" +
      " OR topics.title like '" + I18n.t('blog.prefix.topic') + "%'")
  end

  def self.blogposts
    list_blogposts.map{ |p| BlogPost.new(p) }
  end

  def self.find_blogpost(id)
    t = Topic.secured.visible.listable_topics
      .where("topics.id = ?", id)
    return unless t and t[0]
    BlogPost.new(t[0])
  end

  class BlogPost < Metadata

    def sync_metadata(cooked)
      properties = options(cooked)
      return unless properties
      properties.each{|key, value| add_meta_data(key, value)}
    end

    def self.is_blogpost?(topic)
      return false unless topic

      if topic.category and topic.category.slug == SiteSetting.blog_category
        return true
      end

      topic.title.start_with?(I18n.t('blog.prefix.topic'))
    end

    def properties
      ['todo']
    end

    def author
      @topic.user.name
    end

    def created_at
      @topic.created_at
    end

    def reply_count
      @topic.reply_count
    end

    def prefixes
      Hash[properties.map{|item| [item, I18n.t('blog.prefix.'+item)]}]
    end
  end
end

