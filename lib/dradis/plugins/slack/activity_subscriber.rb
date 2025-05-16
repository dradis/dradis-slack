module Dradis::Plugins::Slack
  class ActivitySubscriber
    def self.handle(payload)
      action = payload[:action]
      trackable = payload[:trackable]
      user = payload[:user]

      text =
        if trackable
          "[Dradis] #{trackable.class.name} ID=#{trackable.id} #{action.sub(/e?\z/, 'ed')} by #{user}"
        else
          "[Dradis] An item was deleted by #{user}"
        end

      Slack::Notifier.new(Dradis::Plugins::Slack::Engine.settings.webhook).post(
        # icon_emoji: ':robot_face:',
        icon_url: Dradis::Plugins::Slack::Engine.settings.icon,
        text: text,
        fields: trackable ? fields_for(trackable) : []
      )
    end

    private
    def self.fields_for(trackable)
      result = []

      options = ActionMailer::Base.default_url_options
      url_helpers = Rails.application.routes.url_helpers
      item_url = url_for(trackable, options, url_helpers)

      # Project
      if trackable.project
        result << {
          title: 'Project',
          value: "<#{url_helpers.project_url(trackable.project, options)}|#{trackable.project.name}>"
        }
      end

      # Title
      title = if trackable.respond_to?(:title) && trackable.title?
        trackable.title
              elsif trackable.respond_to?(:label) && trackable.label?
                trackable.label
              elsif trackable.class.name == 'Comment'
                trackable.commentable.title
      end

      if title.present?
        result << {
          title: 'Title',
          value: "<#{item_url}|#{title}>"
        }
      end

      # Content (for comments)
      if trackable.class.name == 'Comment'
        result << {
          title: 'Content',
          value: trackable.content
        }
      end

      result
    end

    def self.url_for(trackable, options, helpers)
      components = [trackable.project]

      target = trackable.class.name == 'Comment' ? trackable.commentable : trackable

      # Don't need Issue because L74
      case target
      when Card
        components << target.list.board
        components << target.list
      when Evidence, Note
        # FIXME - ISSUE/NOTE INHERITANCE
        unless target.is_a?(Issue)
          components << target.node
        end
      end

      components << target
      helpers.polymorphic_url(components, options)
    end
  end
end
