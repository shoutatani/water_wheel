# frozen_string_literal: true

require "fog/aws"
require "retriable"
require "parallel"

module WaterWheel
  class Backup
    class << self
      def on
        configuration.validate!
        upload!
      end

      private

      def configuration
        WaterWheel.configuration
      end

      def upload!
        upload_files
        upload_directories
      end

      def storage
        @storage ||= Fog::Storage.new(
          provider: "AWS",
          aws_access_key_id: configuration.aws_access_key_id,
          aws_secret_access_key: configuration.aws_secret_access_key,
          region: configuration.aws_region
        )
      end

      def bucket
        storage.directories.get(configuration.aws_bucket_name)
      end

      def upload_files
        return unless configuration.absolute_path_on_files.any?

        configuration.absolute_path_on_files.each do |absolute_file_path|
          next if File.directory?(absolute_file_path)

          upload_file(absolute_file_path)
        end

        WaterWheel.logger.info "Section of uploading files finished."
      end

      def upload_directories
        return unless configuration.absolute_path_on_directories.any?

        configuration.absolute_path_on_directories.each do |absolute_directory_path|
          next unless File.directory?(absolute_directory_path)

          upload_directory(absolute_directory_path)
        end

        WaterWheel.logger.info "Section of uploading directories finished."
      end

      def upload_directory(absolute_directory_path)
        included_files = Dir.glob(File.join(absolute_directory_path, "**", "*"))
        Parallel.each(included_files, in_threads: configuration.parallel_count) do |included_file|
          next if File.directory?(included_file)

          upload_file(included_file)
        end
      end

      def upload_file(absolute_file_path)
        bucket_file_key = create_bucket_key(absolute_file_path)

        begin
          return unless shouldUploadFile?(bucket_file_key, absolute_file_path)

          if configuration.dry_run
            WaterWheel.logger.info "Dry run: Uploading #{absolute_file_path} to #{bucket_file_key}"
            return
          end

          Retriable.retriable do
            bucket.files.create(
              key: bucket_file_key,
              body: File.open(absolute_file_path),
              storage_class: configuration.storage_class
            )
          end
        rescue => exception
          WaterWheel.logger.warn "Failed to upload #{absolute_file_path} to #{bucket_file_key} on #{bucket.key}: #{exception.message}"
        else
          WaterWheel.logger.info "Uploaded #{absolute_file_path} to #{bucket_file_key} on #{bucket.key}"
        end
      end

      def create_bucket_key(absolute_file_path)
        bucket_key = omit_path_prefix(absolute_file_path)
        WaterWheel.logger.debug "bucket_key: #{bucket_key}"
        bucket_key
      end

      def omit_path_prefix(absolute_file_path)
        bucket_file_key = absolute_file_path
        configuration.ordered_omit_path_prefixes.each do |prefix|
          if absolute_file_path.start_with?(prefix)
            bucket_file_key = absolute_file_path.sub(prefix, "")
            break
          end
        end
        bucket_file_key
      end

      def shouldUploadFile?(buckey_file_key, absolute_file_path)
        return false if File.directory?(absolute_file_path)

        file_information = bucket.files.head(buckey_file_key)
        return true if file_information.nil?
        return false if file_information.content_length == File.size(absolute_file_path)
        true
      end
    end
  end
end
