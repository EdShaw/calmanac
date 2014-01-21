PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'mocha/api'
# Specify your app using the #app helper inside a context.
# Takes either an app class or a block argument.
  include Mocha::API
# app { Padrino.application }
# app { Calmanac::App.tap { |app| } }

class Riot::Situation
  include Mocha::API
  include Rack::Test::Methods

  # You can use this method to custom specify a Rack app
  # you want rack-test to invoke:
  #
  #   app Calmanac::App
  #   app Calmanac::App.tap { |a| }
  #   app(Calmanac::App) do
  #     set :foo, :bar
  #   end
  #
  def app(app = nil, &blk)
    @app ||= block_given? ? app.instance_eval(&blk) : app
    @app ||= Padrino.application
  end
end

class Riot::Context
  include Mocha::API
end

