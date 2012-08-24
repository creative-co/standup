class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def index
    @todos = Todo.all
  end
end
