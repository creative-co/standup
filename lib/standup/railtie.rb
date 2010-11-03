require 'standup'
require 'rails'

module Standup
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/standup.rake'
    end
  end
end
