module ::OnepagePlugin
  def self.list_projects
    projects_category_id = Category.query_parent_category(SiteSetting.projects_category);
    return unless projects_category_id

    Topic.visible.listable_topics
      .joins(:category)
      .where("(categories.parent_category_id = ? " +
      " OR categories.id = ? " +
      " AND topics.title not like 'About the%')" +
      " OR topics.title like '" + I18n.t('events.prefix.topic') + "%'", 
      projects_category_id, projects_category_id)
  end

  def self.projects
    list_projects.map{ |p| Project.new(p) }
  end

  def self.find_project(id)
  	t = Topic.secured.visible.listable_topics
      .where("topics.id = ?", id)
    return unless t and t[0]
    Project.new(t[0])
  end

  class Project < Metadata

    def trello
      meta_data("trello")
    end

    def category 
      'siirappi'
    end

    def self.is_project?(topic)
      if topic.category and topic.category.slug == SiteSetting.projects_category
        return true
      end

      topic.title.start_with?(I18n.t('events.prefix.project'))
    end

    def properties
      ['trello']
    end

    def post_counts_by_user
      @post_counts_by_user ||= Post.where(topic_id: @topic.id).group(:user_id).order('count_all desc').limit(24).count
    end

    def participants
      @participants ||= begin
        participants = {}
        User.where(id: post_counts_by_user.map {|k,v| k}).each {|u| participants[u.id] = u}
        participants
      end
    end

    def post
      @post
    end

    def prefixes
      Hash[properties.map{|item| [item, I18n.t('projects.prefix.'+item)]}]
    end

    def sync_metadata(cooked)
      properties = options(cooked)
      return unless properties
      properties.each{|key, value| add_meta_data(key, value)}
    end
  end
end

