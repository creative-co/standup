### Standup

Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2.

## Basic usage

0. `gem install standup`
0. `cd path/to/your/rails/project`
0. `standup init`
0. Fill in actual settings in generated file `config/standup.yml`
0. `standup setup`
0. `standup status`

## Config file

It consists of 3 major parts:

### Amazon Web Services credentials

    aws:
      account_id: 0123-4567-8910
      access_key_id: GTFGV123P45DRDKOBBVP
      secret_access_key: jKkjhkjbb1Bhjh+MBG0GBbmuhdGh/Kgbdhzbd9sd
      keypair_name: aws
      availability_zone: us-east-1c

Here, keypair_name is keypair filename, without `.pem` extension.
By default, Standup searches actual file under `~/.ssh` directory.
You can override this behavior by specifying `keypair_file` param.

### Global script params

    ec2:
      image_id: ami-480df921 # Canonical Ubuntu 10.04, EBS boot
      instance_type: m1.small
      ssh_user: ubuntu
    webapp:
      github_user: supercoder
      github_repo: superproject

Major part of script params can be set here.

### Nodes and their script params

    nodes:
      main:
        ec2:
          elastic_ip: 123.123.123.123
      testing:
      staging:

Here, under `nodes` section, should go actual nodes (server instances) which you want to manage.
For each node, you can specify additional script params.
In this example, `elastic_ip` param of `ec2` script is set for node `main`.

Script params are merged in `node-specific || global || script-defaults` manner.

## Tweaking bundled scripts

0. `standup localize <script_name>`
0. Script file `config/standup/<script_name>.rb` will be copied from gem.
0. Script's own files, like configs etc. under `config/standup/<script_name>`, if any, will be copied from gem too. 
0. You can edit them and standup will use them instead of default.
0. You can delete local script file or its own files, then default ones will be used. 

## Creating new scripts

0. `standup generate <script_name>`
0. Script file `config/standup/<script_name>.rb` will be created with empty script stub.
0. Edit it as you want, it's now available for Standup.

## Setup script

Setup script automates common Rails application deployment workflow.

If you want to add your script into this workflow, just set it as script param, thus overwriting default.

For example, if you want to add `rescue` to your configuration, you need to:

0. Write that `rescue` script
0. Change standup.yml like the following:

        nodes:
          main:
            ...
            setup:
              ec2 basics ruby postgresql passenger rescue webapp update 

## To do

- **?** Script sequences: rework default script as script sequence

## Copyright

Copyright (c) 2010 Ilia Ablamonov, Cloud Castle Inc.
See LICENSE for details.
