module Standup
  begin
    class Settings < Settingslogic
      source 'config/standup.yml'
      load!
  
      aws['account_id'].gsub!(/\D/, '')
      # keypair_file default to ~/.ssh/keypair_name.pem
      aws['keypair_file'] ||= "#{File.expand_path '~'}/.ssh/#{aws.keypair_name}.pem"
    end
  rescue 
    require 'active_support/hash_with_indifferent_access'
    remove_const :Settings
    const_set :Settings, ActiveSupport::HashWithIndifferentAccess.new('nodes' => {})
  end
end
