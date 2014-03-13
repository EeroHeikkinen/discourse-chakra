module ::OnepagePlugin
  def self.list_blogposts
    t = Topic.secured.visible.listable_topics
      .joins(:category)
      .where("(categories.slug = '" + SiteSetting.blog_category + "'" +
      " AND topics.title not like 'About the%')" +
      " OR topics.title like '" + I18n.t('blog.prefix.topic') + "%'")
  end

  def self.blogposts
    list_blogposts.map{ |p| BlogPost.new(p) }
  end

  class BlogPost < Metadata

    def category 
      'siirappi'
    end

    def is_blogpost?
      if @topic.category and @topic.category.slug == SiteSetting.blog_category
        return true
      end

      @topic.title.start_with?(I18n.t('blog.prefix.topic'))
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

