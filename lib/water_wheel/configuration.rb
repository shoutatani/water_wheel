# frozen_string_literal: true

module WaterWheel
  class Configuration
    attr_accessor :provider,
                  :aws_access_key_id,
                  :aws_secret_access_key,
                  :aws_region,
                  :aws_bucket_name,
                  :absolute_path_on_files,
                  :absolute_path_on_directories,
                  :ordered_omit_path_prefixes,
                  :storage_class,
                  :dry_run

    def initialize
      @provider = "AWS"
      @aws_access_key_id = ENV["AWS_ACCESS_KEY_ID"]
      @aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
      @aws_region = ENV["AWS_DEFAULT_REGION"]
      @aws_bucket_name = ENV["WATER_WHEEL_AWS_BUCKET_NAME"]
      @absolute_path_on_files = []
      @absolute_path_on_directories = []
      @ordered_omit_path_prefixes = ["/"]
      @storage_class = "STANDARD"
      @dry_run = false
    end

    def absolute_path_on_files
      @absolute_path_on_files || []
    end

    def absolute_path_on_directories
      @absolute_path_on_directories || []
    end

    def ordered_omit_path_prefixes
      @ordered_omit_path_prefixes || []
    end

    def validate!
      validate_aws_configuration if provider == "AWS"
      validate_backup_target
    end

    private

    def validate_aws_configuration
      %i(aws_access_key_id
         aws_secret_access_key
         aws_region
         aws_bucket_name
      ).each do |key|
       if self.public_send(key).nil? || self.public_send(key).empty?
         error_message = <<~ERROR
           WaterWheel configuration #{key} is missing.
           Please set it as
            `WaterWheel.configure do |config|
               config.#{key} = "value"
             end`
         ERROR
         raise error_message
       end
     end

     def validate_backup_target
      both_upload_target_are_not_set = %i(absolute_path_on_files absolute_path_on_directories).all? do |key|
        self.public_send(key).nil? || self.public_send(key).empty?
      end
      if both_upload_target_are_not_set
        error_message = <<~ERROR
          WaterWheel upload target is empty.
          Please set it as
            `WaterWheel.configure do |config|
               config.absolute_path_on_files = ["/path/to/file1", "/path/to/file2"]
               config.absolute_path_on_directories = ["/path/to/directory1", "/path/to/directory2"]
             end`"
        ERROR
        raise error_message
      end
     end
    end
  end
end
