module Standup
  class Settings < Settingslogic
    source "#{Rails.root}/config/standup.yml"
    load!

    aws['account_id'].gsub!(/\D/, '')
    # keypair_file default to ~/.ssh/keypair_name.pem
    aws['keypair_file'] ||= "#{File.expand_path '~'}/.ssh/#{aws.keypair_name}.pem"
  end
end
