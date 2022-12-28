# frozen_string_literal: true

require "spec_helper"
RSpec.describe Shatter::Service::Function do
  describe "#valid_params?" do
    [
      { val: "not null", nullable: false, type: "string", expected: true },
      { val: "not null", nullable: true, type: "string", expected: true },
      { val: nil, nullable: false, type: "string", expected: false },
      { val: 1, nullable: false, type: "integer", expected: true },
      { val: 1, nullable: true, type: "integer", expected: true },
      { val: nil, nullable: false, type: "integer", expected: false },
      { val: "1", nullable: false, type: "integer", expected: false }
    ].each do |ex|
      context "with #{ex}" do
        subject { func.valid_params? }

        let(:subclass) do
          Class.new(described_class) do
            define_param("val", type: ex[:type], nullable: ex[:nullable])
          end
        end
        let(:func) { subclass.new(uuid: "test-uuid", val: ex[:val]) }

        it { is_expected.to be ex[:expected] }
      end
    end
  end
end
