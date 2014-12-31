require 'current_user'
require_dependency 'discourse'

# add the tags to the serializer
module ProjectParticipantsTopicViewSerializer
  include CurrentUser
  
  def self.included(klass)
    klass.attributes :project
  end

  def project
      return unless OnepagePlugin::Project.is_project?(object.topic)
      @project = OnepagePlugin::Project.new(object.topic)

      return unless object.topic.meta_data
      result = {}
      result[:participants] = @project.participants.map do |u| 
          BasicUserSerializer.new(u, scope: scope, root: false)
      end
      result[:participating] = @project.participating(scope.user)
      result[:can_join] = @project.can_join(scope.user)
      result
  end
end

TopicViewSerializer.send(:include, ProjectParticipantsTopicViewSerializer)