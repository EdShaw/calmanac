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

    redis = URI.parse(ENV["REDISCLOUD_URL"])
    set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(
                                                     :host => redis.host,
                                                     :port => redis.port,
                                                     :password => redis.password
                                                 ))
    get '/' do
      "Hello! :) You can find the lecture time table <a href='./lectures.ics'>here.</a>."
    end

    def filter_calendar(url, courses)

      components = cache( "parsed-cal-#{url}", :expires_in => 60*60*6) do
        ics = Net::HTTP.get(URI.parse(url))
      end
      RiCal.parse_string(ics)

      if courses then
        components[0].events.select! do |c|
          courses.include? c.summary
        end
      end
      components
    end


    def construct_calendar(cal_uri)
      components = filter_calendar(cal_uri, params["courses"])
      content_type 'text/calendar'
      components
    end

    get '/lectures.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Lecture.ics'
      construct_calendar(cal_uri).to_s
    end

    get '/practicals.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Practical.ics'
      construct_calendar(cal_uri).to_s
    end

    get '/classes.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Class.ics'
      construct_calendar(cal_uri).to_s
    end

  end
end
