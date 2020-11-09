module Dradis::Plugins::Slack
  class ActivitySubscriber
    def self.handle(payload)
      activity = payload[:activity]

      Slack::Notifier.new(Dradis::Plugins::Slack::Engine.settings.webhook).post(
        # icon_emoji: ':robot_face:',
        icon_url: Dradis::Plugins::Slack::Engine.settings.icon,
        text: "[Dradis] #{activity.trackable.class.name} #{activity.action.sub(/e?\z/, 'ed')} by #{activity.user.name}",
        fields: fields_for(activity)
      )

    end

    private
    def self.fields_for(activity)
      result = []

      options = ActionMailer::Base.default_url_options
      url_helpers = Rails.application.routes.url_helpers
      item_url = url_for(activity, options, url_helpers)

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
              elsif activity.trackable_type == 'Comment'
                activity.trackable.commentable.title
              end

      if title.present?
        result << {
          title: 'Title',
          value: "<#{item_url}|#{title}>"
        }
      end

      # Content (for comments)
      if activity.trackable_type == 'Comment'
        result << {
          title: 'Content',
          value: activity.trackable.content
        }
      end

      result
    end

    def self.url_for(activity, options, helpers)
      components = [activity.project]

      target = activity.trackable_type == 'Comment' ? activity.trackable.commentable : activity.trackable

      # Don't need Issue because L74
      case target
      when Card
        card = activity.trackable
        components << card.list.board
        components << card.list
      when Evidence, Note
        components << activity.trackable.node
      end

      components << activity.trackable
      helpers.polymorphic_url(components, options)
    end
  end
end
