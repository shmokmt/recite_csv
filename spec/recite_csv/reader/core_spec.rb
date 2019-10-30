# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe ReciteCSV::Reader::Core do
  let(:dummy_class) do
    Class.new do
      include ReciteCSV::Reader::Core
      const_set(:Row, Class.new(ReciteCSV::Row::Base))
      const_set(:DEFAULT_CSV_OPTIONS, headers: :first_row)
    end
  end

  describe "#each" do
    let(:temp_csv) { Tempfile.open("csv") }
    let(:reader) do
      csv_string = CSV.generate do |csv|
        csv << %w[COL1 COL2]
        csv << %w[V1 V2]
      end
      temp_csv.write(csv_string)
      temp_csv.flush
      temp_csv.rewind
      dummy_class.new(temp_csv)
    end
    after { temp_csv.close }

    context "call with a block" do
      it "enumerate with row objects" do
        r = reader.each do |row|
          expect(row).to be_a ReciteCSV::Row::Base
          expect(row["COL1"]).to eq "V1"
          expect(row["COL2"]).to eq "V2"
        end
        expect(r).to equal reader
      end
    end

    context "call without a block" do
      subject { reader.each }

      it { is_expected.to be_a Enumerator }
    end
  end
end
