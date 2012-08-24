if File.exists?('config/standup.yml')
  class Standup::Settings < Settingslogic
    source 'config/standup.yml'
    load!

    aws['account_id'].gsub!(/\D/, '') if aws['account_id']
    # keypair_file default to ~/.ssh/keypair_name.pem
    aws['keypair_file'] ||= "#{File.expand_path '~'}/.ssh/#{aws.keypair_name}.pem"
  end
else
  Standup.const_set :Settings, ActiveSupport::HashWithIndifferentAccess.new('nodes' => {})
end
