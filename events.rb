module ::OnepagePlugin
  def self.list
    t = Topic.secured.visible.listable_topics
      .joins(:category)
      .where("(categories.slug = '" + SiteSetting.events_category + "'" +
      " AND topics.title not like 'About the%')" +
      " OR topics.title like '" + I18n.t('events.prefix.topic') + "%'")
      .order("meta_data->'event_date' ASC")
  end

  def self.events
    list.map{ |e| Event.new(e) }
  end

  class Event < Metadata

    def city
      meta_data("event_city")
    end

    def date
      meta_data("event_date")
    end

    def place
      meta_data("event_place")
    end

    def time
      meta_data("event_time")
    end

    def past
      date ? Date.yesterday > date.to_datetime : false
    end

    def short_date
      return unless date
      d = date.to_datetime

      "#{d.day}.#{d.month}"
    end

    def is_event?
      # All topics in events category are events
      if @topic.category and @topic.category.slug == SiteSetting.events_category
        return true
      end

      @topic.title.start_with?(I18n.t('events.prefix.topic'))
    end

    def properties
      ['place', 'time', 'city', 'date']
    end

    def prefixes
      Hash[properties.map{|item| [item, I18n.t('events.prefix.'+item)]}]
    end

  end

  def sync_metadata
    properties = options
    if properties["date"]
      properties["date"] = Time.strptime(properties["date"], "%d.%m.%Y")

      if(SiteSetting.googlecalendar_enabled)
        if(properties["time"])
          start_time, end_time = properties["time"].split("-").collect(&:strip)

          if(start_time)
            hours, minutes = start_time.split(":").collect(&:to_i)
            start_time = properties["date"] + hours.hours + minutes.minutes
          else
            start_time = properties["date"]
          end

          if(end_time)
            hours, minutes = end_time.split(":").collect(&:to_i)
          end

          if end_time and hours and minutes
            end_time = properties["date"] + hours.hours + minutes.minutes
          else
            end_time = start_time
          end

          sync_google_calendar(topic.title, start_time, end_time)
        else
          sync_google_calendar(topic.title, properties["date"], properties["date"]+24.hours)
        end          
      end
    end

    properties.each{|key, value| add_meta_data("event_" + key, value)}
  end

  def sync_google_calendar(title, start_time, end_time)
    cal = Google::Calendar.new(:username => SiteSetting.googlecalendar_username,
                         :password => SiteSetting.googlecalendar_password,
                         :app_name => 'Yhteinen-googlecalendar-integration')
    return nil unless title and start_time and end_time
    
    if topic.meta_data && topic.meta_data["calendar_event_id"]
      calendar_event_id = topic.meta_data["calendar_event_id"]
    end

    event = cal.find_or_create_event_by_id(calendar_event_id) do |e|
      e.title = self.topic.title
      e.start_time = start_time
      e.end_time = end_time 
    end

    Rails.logger.info("Updated event #{event}")

    add_meta_data("calendar_event_id", event.id)
  end
end

