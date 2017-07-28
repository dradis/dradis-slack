require_relative 'gem_version'

module Dradis
  module Plugins
    module Slack
      # Returns the version of the currently loaded Slack integration as a
      # <tt>Gem::Version</tt>.
      def self.version
        gem_version
      end
    end
  end
end
