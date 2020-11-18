RSpec.describe Healthcheck do
  let(:subject) { Healthcheck.check }

  let(:active_record) { double(:active_record, connection: true) }

  before do
    stub_const("ActiveRecord::Base", active_record)
  end

  context "database connectivity" do
    context "the database is connected" do
      it "returns :ok" do
        expect(subject.dig(:checks, :database_connectivity, :status)).to be(:ok)
      end
    end

    context "the database is not connected" do
      before do
        allow(active_record).to receive(:connection) { raise }
      end

      it "returns :critical" do
        expect(subject.dig(:checks, :database_connectivity, :status)).to be(:critical)
      end

      it "sets the overall status to :critical" do
        expect(subject.dig(:status)).to be(:critical)
      end
    end
  end
end
