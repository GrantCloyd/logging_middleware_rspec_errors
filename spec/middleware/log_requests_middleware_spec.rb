require 'rails_helper'

RSpec.describe LogRequestsMiddleware do
  describe 'stack trace error possibilities' do
    let(:subject) { LogRequestsMiddleware.new(app) }
    let(:env) { Rack::MockRequest.env_for }
    
    context "#call" do
      context 'if request does not respond to first' do
        let(:app) {  lambda { |env| [200, {'Content-Type' => 'text/plain'}, nil] } } 

        it "will throw a NoMethodError when hitting request.first" do
          expect { subject.call(env) }.to raise_error(NoMethodError, "undefined method `first' for nil")
        end
      end

      context 'if request attribute does not respond to body' do
        let(:env) { nil }
        let(:app) {  lambda { |env| [200, {'Content-Type' => 'text/plain'}, nil] } } 

        it "will throw a NoMethodError" do
          expect { subject.call(env) }.to raise_error(NoMethodError, "undefined method `[]' for nil")
        end
      end

      context 'if request body is returned as nil' do
        let(:app) {  lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['Ok'] ] } } 
        
    
        it "will throw a NoMethodError when attempting to parse json" do
          request = double
    
          expect(Rack::Request).to receive(:new).and_return(request)
          expect(request).to receive(:body).and_return(nil)
    
          expect { subject.call(env) }.to raise_error(NoMethodError, "undefined method `read' for nil")
        end
      end
    end #end of #call

    context "#log_request_and_response!" do 
      let(:app) {  lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['Ok'] ] } }
      let(:request) { "" }
      let(:headers) { "looks good" }
      let(:url) { '/users' }
      let(:response) { "[{\"id\":1,\"name\":\"Name 0\"}]"}
        
      context 'if request is nil' do
        let(:request) { nil}
        it "will throw a NoMethodError when attempting to parse request json" do

          expect do
            subject.log_request_and_response!(request:, headers:, url:, response:) 
          end
          .to raise_error(NoMethodError, "undefined method `empty?' for nil")
        end
      end

      context 'if response is nil' do
        let(:response) { nil }
        it "will throw a NoMethodError when attempting to parse request json" do

          expect do
            subject.log_request_and_response!(request:, headers:, url:, response:) 
          end
          .to raise_error(NoMethodError, "undefined method `empty?' for nil")
        end
      end

      context 'if Log.create! triggers a validation error' do
        # note, for this example, since Log is an ambiguous class, I created a 
        # Log class/migration that requires url is not nil and added that validation to the class
        let(:url) { nil }

        it 'will throw a record invalid error' do
          expect do 
            subject.log_request_and_response!(request:, headers:, url:, response:) 
          end
          .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Url can't be blank")
        end
      end
    end # end of #log_request_and_response!
  end
end