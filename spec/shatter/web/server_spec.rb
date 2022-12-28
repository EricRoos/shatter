# frozen_string_literal: true

require "spec_helper"

require "rack"
RSpec.describe Shatter::Web::Server do
  describe "invoking an rpc request" do
    let(:mock_request) do
      Rack::MockRequest.env_for("/hello_world", method: "POST", params: {})
    end
    let(:mock_application) do
      Class.new(Shatter::Web::Application) do
        def service_client
          Class.new(Shatter::Service::Base) do
            def self.hello_world(_params)
              "hello_world"
            end
          end
        end
      end
    end
    let(:mock_service_definition) do
      Class.new(Shatter::Service::ServiceDefinition) do
        self.function_collection = { "hello_world" => true }
      end
    end

    before do
      Shatter::Service::Base.service_definition = mock_service_definition
      described_class.application = mock_application
    end

    describe "the status" do
      subject { described_class.call(mock_request)[0] }

      it { is_expected.to eq 200 }
    end

    describe "the headers" do
      subject { described_class.call(mock_request)[1] }

      it { is_expected.to include("delay" => 100) }
      it { is_expected.to include("location") }
    end

    context "when the rpc method is missing" do
      subject { described_class.call(mock_request)[0] }

      let(:mock_request) do
        Rack::MockRequest.env_for("/missing", method: "POST", params: {})
      end

      it { is_expected.to eq 200 }
    end
  end

  describe "something i dont expect to receive" do
    subject { described_class.call(mock_request)[0] }

    let(:mock_request) do
      Rack::MockRequest.env_for("/admin", method:, params: {})
    end

    %i[PUT PATCH DELETE GET].each do |http_method|
      context "when method is #{http_method}" do
        let(:method) { http_method }

        it { is_expected.to eq 404 }
      end
    end
  end
end
