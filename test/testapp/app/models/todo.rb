class Todo < ActiveRecord::Base
  validate :text, presence: true
  attr_accessible :text, :done
end