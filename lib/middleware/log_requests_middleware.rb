class LogRequestsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    request = Rack::Request.new(env)
    request_body = request.body.read # hard to imagine why env shouldn't be here, but could do request&.body&.read if we're worried about stack traces
    # change here; passed response.first to response kwarg
    # response_body = response&.body
    log_request_and_response!(request: request_body, headers: env["HTTP_AUTHORIZATION"], url: request.path, response: response.first) # change to response_body, confirm request responds to path


    [status, headers, response]
  end

  def log_request_and_response!(request:, headers:, url:, response:)
    return if ['swagger', 'favicon.ico'].include?(url)
    # worth checking that it's json first
    request = JSON.parse(request) unless request.empty? # change to blank? to account for nil
    response = JSON.parse(response) unless response.empty? # change to blank? to account for nil
    # unsure what Log class validations are but it uses create! so validations will be checked
    Log.create!(
      request: request,
      headers: headers,
      # example, what if urls are nil?
      url: url,
      response: response
    )
    # rescue ActiveRecord::RecordInvalid => e
    # log_hash = { 
    #              error: e.errors.messages  
    #              request: request,
    #              headers: headers,
    #              url: url,
    #              response: response
    #             }
    # Rails.logger.info log_hash
    # end
  end
end