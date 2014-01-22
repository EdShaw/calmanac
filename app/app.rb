require 'ri_cal'
require 'net/http'
require "redis"
require "sinatra"

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
      puts settings.public_folder
      send_file File.join(settings.public_folder, 'index.html')
    end

    def filter_calendar(url, courses)

      components = get_components(url)
      if courses then
        components[0].events.select! do |c|
          courses.include? c.summary
        end
      end
      components
    end

    def get_components(url)
      ics = cache("base-cal-#{url}", :expires_in => 60*60*6) do
        Net::HTTP.get(URI.parse(url))
      end
      components = RiCal.parse_string(ics)
    end


    def construct_calendar(cal_uri)
      components = filter_calendar(cal_uri, params["courses"])
      components[0]
    end

    get '/lectures.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Lecture.ics'
      if !params["debug"]
        content_type 'text/calendar'
      end
      construct_calendar(cal_uri).to_s
    end

    get '/practicals.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Practical.ics'
      if !params["debug"]
        content_type 'text/calendar'
      end
      construct_calendar(cal_uri).to_s
    end

    get '/classes.ics' do
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Class.ics'
      if !params["debug"]
        content_type 'text/calendar'
      end
      construct_calendar(cal_uri).to_s
    end

    require 'set'
    require 'json'

    def get_courses()
      cal_uri = 'http://www.cs.ox.ac.uk/feeds/Timetable-Lecture.ics'
      components = get_components(cal_uri)
      names = Set.new
      components[0].events.each { |event| names.add(event.summary) }
      names
    end

    get '/api/coursenames', :cache => true do
      expires_in 60*60*2
      cache_key "api-courses"
      names = get_courses()
      content_type :json
      JSON.generate(names.to_a)
    end

  end
end
