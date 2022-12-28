# frozen_string_literal: true

require "spec_helper"

RSpec.describe Shatter::Service::ServiceDefinition do
  describe "::register_function" do
    subject { described_class.function_collection }

    let(:op_name) { "foo" }
    let(:invoke_result) { double }
    let(:func) do
      Class.new(Shatter::Service::Function) do
        def invoke
          { error: nil, result: :result }
        end
      end
    end

    before do
      described_class.register_function(op_name, func)
    end

    it { is_expected.to include("foo" => func) }

    describe "the registered methods" do
      subject { described_class.new }

      it { is_expected.to respond_to(:foo) }
    end
  end
end
