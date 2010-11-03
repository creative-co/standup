### Standup

Standup is an application deployment and infrastructure management tool for Rails and Amazon EC2.

## Basic Usage

0. Add `gem 'standup'` into Gemfile and install it via `> bundle install`
0. `> rake standup:init`
0. Write actual settings in generated `config/standup.yml`
0. `> rake standup:setup`
0. `> rake standup:status`

## Tweaking default scripts

0. `> rake standup:localize SCRIPT=<script_name>`
0. Script file `config/standup/<script_name>.rb` will be copied from gem.
0. Script's own files, like configs etc. under `config/standup/<script_name>`, if any,  will be copied from gem too. 
0. You can edit them and standup will use them instead of default.
0. You can delete local script's own files, then default ones will be used. 

## Creating new scripts

0. `> rake standup:generate SCRIPT=<script_name>`
0. Script file `config/standup/<script_name>.rb` will be created with empty script stub.
0. Edit it as you want, it's now available for standup.

## Setup script

Setup script is just common Rails application deployment workflow.

If you just want to add your script into this workflow, just set it as script param, thus overwriting default.

For example, if you want to add `rescue` to your configuration, you need to:

0. Write that `rescue` script
0. Change standup.yml like the following:

        nodes:
          main:
            ...
            setup:
              ec2 basics ruby postgresql passenger rescue webapp update 

## Copyright

Copyright (c) 2010 Ilia Ablamonov, Cloud Castle Inc.
See LICENSE for details.
