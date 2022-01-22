# frozen_string_literal: true

require 'fog/aws'

RSpec.describe WaterWheel::Backup do
  before(:all) do
    Fog.mock!
    WaterWheel.logger = Logger.new($stdout).tap do |log|
      log.level = Logger::WARN
    end
  end

  before(:each) do
    WaterWheel.reset
    WaterWheel.configuration.provider = "AWS"
    aws_credentials = %i(aws_access_key_id aws_secret_access_key aws_region aws_bucket_name)
    aws_credentials.each do |aws_credential_key|
      WaterWheel.configuration.public_send("#{aws_credential_key}=", "dummy_value")
    end
    storage.directories.create(key: WaterWheel.configuration.aws_bucket_name)
  end

  after(:each) do
    bucket.files.each do |file|
      file.destroy
    end
    bucket.destroy
  end

  def storage
    WaterWheel::Backup.send(:storage)
  end

  def bucket
    WaterWheel::Backup.send(:bucket)
  end

  describe "#on" do
    context "when provider is AWS" do
      let(:backup_file) { File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__) }
      let(:backup_file_2) { File.expand_path('./fixtures/files/dummy_file_for_test_2.txt', __dir__) }
      let(:backup_directory) { File.expand_path('./fixtures/files/dummy_files_for_test/', __dir__) }
      let(:backup_directory_2) { File.expand_path('./fixtures/files/dummy_files_for_test_2/', __dir__) }
      let(:backup_directory_blank) { File.expand_path('./fixtures/files/dummy_blank_directory/', __dir__) }

      describe "upload files specified by absolute_path_on_files" do
        before do
          WaterWheel.configuration.absolute_path_on_directories = [backup_directory_blank]
        end
        context "when absolute_path_on_files is empty" do
          before do
            WaterWheel.configuration.absolute_path_on_files = []
            WaterWheel::Backup.on
          end

          it "does not upload any files" do
            expect(bucket.files.size).to eq 0
          end
        end

        context "when absolute_path_on_files is not empty" do
          context "when absolute_path_on_files contains only one file" do
            before do
              WaterWheel.configuration.absolute_path_on_files = [backup_file]
              WaterWheel::Backup.on
            end

            it "uploads files specified by absolute_path_on_files" do
              expect(bucket.files.size).to eq 1
            end
          end

          context "when absolute_path_on_files contains some files" do
            before do
              WaterWheel.configuration.absolute_path_on_files = [backup_file, backup_file_2]
              WaterWheel::Backup.on
            end

            it "uploads files specified by absolute_path_on_files" do
              expect(bucket.files.size).to eq 2
            end
          end
        end
      end

      describe "upload directories specified by absolute_path_on_directories" do
        before do
          WaterWheel.configuration.absolute_path_on_files = [backup_file]
        end

        context "when absolute_path_on_directories is empty" do
          before do
            WaterWheel.configuration.absolute_path_on_directories = []
            WaterWheel::Backup.on
          end

          it "does not upload any directories" do
            expect(bucket.files.size).to eq 1
          end
        end

        context "when absolute_path_on_directories is not empty" do
          context "when absolute_path_on_directories contains only one directory" do
            before do
              WaterWheel.configuration.absolute_path_on_directories = [backup_directory]
              WaterWheel::Backup.on
            end

            it "uploads files specified by absolute_path_on_files" do
              expect(bucket.files.size).to eq 6
            end
          end

          context "when absolute_path_on_directories contains some directories" do
            before do
              WaterWheel.configuration.absolute_path_on_directories = [backup_directory, backup_directory_2]
              WaterWheel::Backup.on
            end

            it "uploads files specified by absolute_path_on_files" do
              expect(bucket.files.size).to eq 7
            end
          end
        end
      end

      describe "directories on absolute_path_on_files are not uploaded" do
        before do
          backup_directory = File.expand_path('./fixtures/files/dummy_files_for_test/', __dir__)
          WaterWheel.configuration.absolute_path_on_files = [backup_directory]
          WaterWheel.configuration.absolute_path_on_directories = []
          WaterWheel::Backup.on
        end

        it "does not upload directories on absolute_path_on_files" do
          expect(bucket.files.size).to eq 0
        end
      end

      describe "files on absolute_path_on_directories are not uploaded" do
        before do
          backup_file = File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__)
          WaterWheel.configuration.absolute_path_on_files = []
          WaterWheel.configuration.absolute_path_on_directories = [backup_file]
          WaterWheel::Backup.on
        end

        it "does not upload files on absolute_path_on_directories" do
          expect(bucket.files.size).to eq 0
        end
      end

      describe "same files estimated by file name and file size aren't upload" do
        before do
          backup_file = File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__)
          backup_directory = File.expand_path('./fixtures/files/dummy_files_for_test/', __dir__)
          WaterWheel.configuration.absolute_path_on_files = [backup_file]
          WaterWheel.configuration.absolute_path_on_directories = [backup_directory]
          WaterWheel::Backup.on
          WaterWheel::Backup.on
        end

        it "uploads files only 1 time" do
          expect(bucket.files.size).to eq 6
        end
      end

      describe "bucket key" do
        context "when ordered_omit_path_prefixes is empty" do
          before do
            backup_file = File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__)
            WaterWheel.configuration.absolute_path_on_files = [backup_file]
            WaterWheel.configuration.ordered_omit_path_prefixes = []
            WaterWheel::Backup.on
          end

          it "backup on file name as real hierarchy" do
            expect(bucket.files.first.key).to eq backup_file
          end
        end
        context "when ordered_omit_path_prefixes is not empty" do
          context "when ordered_omit_path_prefixes contains only one prefix" do
            before do
              backup_file = File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__)
              WaterWheel.configuration.absolute_path_on_files = [backup_file]
              omit_prefix = File.expand_path('./fixtures', __dir__) + '/'
              WaterWheel.configuration.ordered_omit_path_prefixes = [omit_prefix]
              WaterWheel::Backup.on
            end

            it "backup on file name considering omit_path_prefixes" do
              expect(bucket.files.first.key).to eq "files/dummy_file_for_test.txt"
            end
          end
          context "when ordered_omit_path_prefixes contains some prefixes" do
            before do
              backup_file = File.expand_path('./fixtures/files/dummy_file_for_test.txt', __dir__)
              WaterWheel.configuration.absolute_path_on_files = [backup_file]
              omit_prefix = File.expand_path('./not/match/', __dir__) + '/'
              omit_prefix_2 = '/'
              WaterWheel.configuration.ordered_omit_path_prefixes = [omit_prefix, omit_prefix_2]
              WaterWheel::Backup.on
            end

            it "backup on file name considering omit_path_prefixes" do
              expect(bucket.files.first.key).to eq backup_file.slice(1..-1)
            end
          end
        end
      end
    end
  end
end
