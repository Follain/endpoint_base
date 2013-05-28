require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'active_support/core_ext/hash'

module Sinatra
  module IntegratorUtils

    module Helpers
      def config(message)
        conf = message[:payload]['parameters'] || []

        conf.inject({}) do |result, param|
          param.symbolize_keys!
          result[param[:name]] = param[:value]
          result
        end
      end

      def process_result(code, response)
        status code
        json response
      end
    end

    def self.registered(app)

      app.helpers Sinatra::JSON
      app.helpers IntegratorUtils::Helpers

      app.set :public_folder, './public'

      app.before do
        if request.get? && request.path_info == '/'
          redirect '/endpoint.json'
        else
          halt 401 if request.env["HTTP_X_AUGURY_TOKEN"] != ENV['ENDPOINT_KEY']
        end

        if request.post?
          begin
            @message = ::JSON.parse(request.body.read).symbolize_keys
            @config = config(@message)
          rescue Exception => e
            halt 406
          end
        end
      end

    end

  end

  register IntegratorUtils
end
