require 'ri_cal'
require 'net/http'
require "redis"

module Calmanac
  class App < Padrino::Application
    register SassInitializer
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Cache
    enable :sessions
    enable :caching

    uri = URI.parse(ENV["REDISCLOUD_URL"])
    puts uri
    set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(
                                                     :host => uri.host,
                                                     :port => uri.port,
                                                     :password => uri.password
                                                 ))
    get '/' do
      "Hello! :) You can find the lecture time table <a href='./lectures.ics'>here.</a> "
    end

    def filter_calendar(ics, courses)
      components = RiCal.parse_string(ics)

      if courses then
        components[0].events.select! do |c|
          courses.include? c.summary
        end
      end
      components
    end

    def get_ics(url)
      cache( "base-cal-#{url}", :expires_in => 60*60*6 ) do
          Net::HTTP.get(URI.parse('http://www.cs.ox.ac.uk/feeds/Timetable-Lecture.ics'))
      end
    end

    get '/lectures.ics' do
      ics = get_ics('http://www.cs.ox.ac.uk/feeds/Timetable-Lecture.ics')
      components = filter_calendar(ics, params["courses"])
      content_type 'text/calendar'
      components[0].to_s
    end

    get '/practicals.ics' do
      ics = get_ics('http://www.cs.ox.ac.uk/feeds/Timetable-Practical.ics')
      components = filter_calendar(ics, params["courses"])
      content_type 'text/calendar'
      components[0].to_s
    end

    get '/classes.ics' do
      ics = get_ics('http://www.cs.ox.ac.uk/feeds/Timetable-Class.ics')
      components = filter_calendar(ics, params["courses"])
      content_type 'text/calendar'
      components[0].to_s
    end

  end
end
