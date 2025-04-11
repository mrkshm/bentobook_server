# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateUniqueFilenameService do
  describe ".call" do
    subject(:generate) { described_class.call(**params) }

    let(:params) { { original_filename: original_filename } }
    let(:original_filename) { "test.jpg" }

    it "generates a filename with random alphanumeric string" do
      result = generate
      expect(result).to match(/\A[a-zA-Z0-9]{12}\.jpg\z/)
    end

    context "with custom size" do
      let(:params) { { original_filename: original_filename, size: 8 } }

      it "generates filename with specified length" do
        result = generate
        expect(result).to match(/\A[a-zA-Z0-9]{8}\.jpg\z/)
      end
    end

    context "with prefix" do
      let(:params) { { original_filename: original_filename, prefix: :avatar } }

      it "includes prefix in filename" do
        result = generate
        expect(result).to match(/\Aavatar_[a-zA-Z0-9]{12}\.jpg\z/)
      end

      context "when prefix is invalid" do
        let(:params) { { original_filename: original_filename, prefix: :invalid } }

        it "raises ValidationError" do
          expect { generate }.to raise_error(
            GenerateUniqueFilenameService::ValidationError,
            "Invalid prefix: invalid"
          )
        end
      end
    end

    context "with suffix" do
      let(:params) { { original_filename: original_filename, suffix: :thumb } }

      it "includes suffix in filename" do
        result = generate
        expect(result).to match(/\A[a-zA-Z0-9]{12}_thumb\.jpg\z/)
      end

      context "when suffix is invalid" do
        let(:params) { { original_filename: original_filename, suffix: :invalid } }

        it "raises ValidationError" do
          expect { generate }.to raise_error(
            GenerateUniqueFilenameService::ValidationError,
            "Invalid suffix: invalid"
          )
        end
      end
    end

    context "with prefix and suffix" do
      let(:params) { { original_filename: original_filename, prefix: :avatar, suffix: :thumb } }

      it "includes both in filename" do
        result = generate
        expect(result).to match(/\Aavatar_[a-zA-Z0-9]{12}_thumb\.jpg\z/)
      end
    end

    context "with invalid extension" do
      let(:original_filename) { "test.invalid" }

      it "raises ValidationError" do
        expect { generate }.to raise_error(
          GenerateUniqueFilenameService::ValidationError,
          "Invalid file extension: .invalid"
        )
      end
    end

    context "with no extension" do
      let(:original_filename) { "test" }

      it "defaults to .webp" do
        result = generate
        expect(result).to match(/\A[a-zA-Z0-9]{12}\.webp\z/)
      end
    end

    context "with invalid size" do
      let(:params) { { original_filename: original_filename, size: 0 } }

      it "raises ValidationError" do
        expect { generate }.to raise_error(
          GenerateUniqueFilenameService::ValidationError,
          "Size must be positive"
        )
      end
    end

    context "with blank filename" do
      let(:original_filename) { "" }

      it "raises ValidationError" do
        expect { generate }.to raise_error(
          GenerateUniqueFilenameService::ValidationError,
          "Original filename cannot be blank"
        )
      end
    end

    context "with nil filename" do
      let(:original_filename) { nil }

      it "raises ValidationError" do
        expect { generate }.to raise_error(
          GenerateUniqueFilenameService::ValidationError,
          "Original filename cannot be blank"
        )
      end
    end

    context "with mixed case extensions" do
      let(:original_filename) { "test.JPG" }

      it "normalizes extension to lowercase" do
        result = generate
        expect(result).to match(/\A[a-zA-Z0-9]{12}\.jpg\z/)
      end
    end
  end
end
