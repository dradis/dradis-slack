module Dradis::Plugins::Slack
  class ActivitySubscriber
    def self.handle(event)
      activity = event.payload[:activity]

      Slack::Notifier.new(settings.webhook).post(
        # icon_emoji: ':robot_face:',
        icon_url: settings.icon,
        text: "[Dradis] #{trackable.class.name} #{action.sub(/e?\z/, 'ed')} by #{user}",
        fields: fields_for(activity)
      )

    end

    private
    def self.fields_for(activity)
      result = []

      options = ActionMailer::Base.default_url_options
      url_helpers = Rails.application.routes.url_helpers
      item_url = url_for(activity, options)

      # Project
      if activity.project
        result << {
          title: 'Project',
          value: "<#{url_helpers.project_url(activity.project, options)}|#{activity.project.name}>"
        }
      end

      # Title
      title = if activity.trackable.respond_to?(:title) && activity.trackable.title?
                activity.trackable.title
              elsif activity.trackable.respond_to?(:label) && activity.trackable.label?
                activity.trackable.label
              end

      if title.present?
        result << {
          title: 'Title',
          value: "<#{item_url}|#{title}>"
        }
      end

      # Content (for comments)
      if activity.trackable == 'Comment'
        result << {
          title: 'Content',
          value: activity.trackable.content
        }
      end

      result
    end

    def self.url_for(activity, options)
      components = [activity.project]

      case activity.trackable
      when Card
        card = activity.trackable
        components << card.list.board
        components << card.list
      when Evidence, Note
        components << activity.trackable.node
      end

      components << activity.trackable
      polymorphic_url(components, options)
    end
  end
end
