module ::OnepagePlugin
  def self.list_projects
    projects_category_id = Category.query_parent_category(SiteSetting.projects_category);
    return unless projects_category_id

    Topic.visible.listable_topics
      .joins(:category)
      .where("((categories.parent_category_id = ? " +
      " OR categories.id = ? )" +
      " AND topics.title not like 'About the%')" +
      " OR topics.title like '" + I18n.t('projects.prefix.topic') + "%'", 
      projects_category_id, projects_category_id)
  end

  def self.projects
    list_projects.map{ |p| Project.new(p) }
  end

  def self.find_project(id)
  	t = Topic.visible.listable_topics
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
      return false unless topic

      projects_category_id = Category.query_parent_category(SiteSetting.projects_category);
      return unless projects_category_id

      if topic.category and (topic.category.id == projects_category_id or topic.category.parent_category_id == projects_category_id)
        return true
      end

      topic.title.start_with?(I18n.t('events.prefix.project'))
    end

    def properties
      ['trello']
    end

    def participant_ids
      p = eval(meta_data("project_participants")) rescue []
      return [p] unless p.kind_of?(Array)
      p
    end

    def participants
      User.where(id: participant_ids)
    end

    def participating(user) 
      return false unless user
      participant_ids.include? user.id
    end

    def add_participant(user)
      return unless user
      add_meta_data("project_participants", participant_ids << user.id)
    end

    def remove_participant(user)
      return unless user
      add_meta_data("project_participants", participant_ids - [user.id])
    end

    def body 
      split = @post.cooked.gsub("<hr/>", "<hr>").split("<hr>")

      if split.length > 1
        return split[1]
      end
      return @post.cooked
    end

    def post
      @post
    end

    def can_join(user)
      return true unless participating(user)
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

