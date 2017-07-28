module Dradis::Plugins::Slack
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Slack

    include Dradis::Plugins::Base
    provides :addon
    description 'Integrates Dradis with Slack to receive project notificaitons in your channel.'

    addon_settings :slack do
      settings.default_webhook = 'https://hooks.slack.com/services/XXXX/YYYY/ZZZZ'
    end


    ActiveSupport::Notifications.subscribe('activity') do |_, _, _, _, payload|
      action    = payload[:action].to_s
      trackable = payload[:trackable]
      user      = payload[:user]

      notifier  = Slack::Notifier.new(settings.webhook)
      notifier.ping "[Dradis activity] #{trackable.class.name} #{action.sub(/e?\z/, 'ed')} by #{user}"
    end
  end
end
