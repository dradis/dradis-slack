module Dradis::Plugins::Slack
  class Engine < ::Rails::Engine
    isolate_namespace Dradis::Plugins::Slack

    include Dradis::Plugins::Base
    provides :addon
    description 'Integrates Dradis with Slack to receive project notifications in your channel.'

    addon_settings :slack do
      settings.default_icon    = 'https://raw.githubusercontent.com/dradis/dradis-ce/master/app/assets/images/logo_small.png'
      settings.default_webhook = 'https://hooks.slack.com/services/XXXX/YYYY/ZZZZ'
    end


    ActiveSupport::Notifications.subscribe('activity') do |_, _, _, _, payload|
      ActivitySubscriber.handle(payload)
    end
  end
end
