# frozen_string_literal: true

RSpec.describe WaterWheel::Configuration do
  before(:each) do
    WaterWheel.reset
  end

  context "when provider is AWS" do
    before do
      WaterWheel.configuration.provider = "AWS"
    end
    describe "#validate!" do
      aws_credentials = %i(aws_access_key_id aws_secret_access_key aws_region aws_bucket_name)
      describe "aws credentials" do
        aws_credentials.each do |test_target_key|
          context "when parts of aws credentials(#{test_target_key}) are not set" do
            before do
              aws_credentials.each do |aws_credential_key|
                test_value = if aws_credential_key == test_target_key
                               nil
                             else
                               "dummy_value"
                             end
                WaterWheel.configuration.public_send("#{aws_credential_key}=", test_value)
              end
            end
            it "raises error about #{test_target_key} is not set" do
              expect { WaterWheel.configuration.validate! }.to raise_error(an_instance_of(RuntimeError).and having_attributes(message: /#{test_target_key.to_s}/))
            end
          end
        end
      end

      backup_targets = %i(absolute_path_on_directories absolute_path_on_files)
      describe "backup targets" do
        before do
          aws_credentials.each do |aws_credential_key|
            WaterWheel.configuration.public_send("#{aws_credential_key}=", "dummy_value")
          end
        end
        context "when backup_targets are not set" do
          before do
            backup_targets.each do |upload_target|
              WaterWheel.configuration.public_send("#{upload_target}=", [])
            end
          end
          it "raises error about backup_targets are not set" do
            expect { WaterWheel.configuration.validate! }.to raise_error(RuntimeError) do |error|
              expect(error.message).to match(/absolute_path_on_files/)
              expect(error.message).to match(/absolute_path_on_directories/)
            end
          end
        end
        context "when backup_targets are both set" do
          before do
            backup_targets.each do |upload_target|
              WaterWheel.configuration.public_send("#{upload_target}=", ["dummy_value"])
            end
          end
          it "does not raise error" do
            expect { WaterWheel.configuration.validate! }.not_to raise_error
          end
        end
        backup_targets.each do |test_target_key|
          context "when only #{test_target_key} is set on backup_targets" do
            before do
              backup_targets.each do |target|
                test_value = if target == test_target_key
                               []
                             else
                               "dummy_value"
                             end
                WaterWheel.configuration.public_send("#{target}=", test_value)
              end
            end
            it "does not raise error" do
              expect { WaterWheel.configuration.validate! }.not_to raise_error
            end
          end
        end
      end

      describe "parallel_count" do
        before do
          aws_credentials.each do |aws_credential_key|
            WaterWheel.configuration.public_send("#{aws_credential_key}=", "dummy_value")
          end
          backup_targets.each do |upload_target|
            WaterWheel.configuration.public_send("#{upload_target}=", ["dummy_value"])
          end
        end
        context "when parallel_count is not set" do
          context "when parallel_count is set as nil" do
            before do
              WaterWheel.configuration.parallel_count = nil
            end
            it "raises error about parallel_count is not set" do
              expect { WaterWheel.configuration.validate! }.to raise_error(RuntimeError) do |error|
                expect(error.message).to match(/parallel_count/)
              end
            end
          end
          context "when parallel_count is set as 0" do
            before do
              WaterWheel.configuration.parallel_count = 0
            end
            it "raises error about parallel_count is not set" do
              expect { WaterWheel.configuration.validate! }.to raise_error(RuntimeError) do |error|
                expect(error.message).to match(/parallel_count/)
              end
            end
          end
          context "when parallel_count is set as minus value" do
            before do
              WaterWheel.configuration.parallel_count = -1
            end
            it "raises error about parallel_count is not set" do
              expect { WaterWheel.configuration.validate! }.to raise_error(RuntimeError) do |error|
                expect(error.message).to match(/parallel_count/)
              end
            end
          end
        end
        context "when parallel_count is set" do
          before do
            WaterWheel.configuration.parallel_count = 10
          end
          it "does not raise error" do
            expect { WaterWheel.configuration.validate! }.not_to raise_error
          end
        end
      end
    end
  end

  describe "gem setting" do
    it "has a version number" do
      expect(WaterWheel::VERSION).not_to be nil
    end
  end
end
