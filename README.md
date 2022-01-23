# WaterWheel

[![Gem Version](https://badge.fury.io/rb/water_wheel.svg)](https://badge.fury.io/rb/water_wheel)
[![RSpec](https://github.com/shoutatani/water_wheel/actions/workflows/main.yml/badge.svg)](https://github.com/shoutatani/water_wheel/actions/workflows/main.yml)

Backup your local files or directories into cloud storages.

Now AWS S3 (Simple Storage Service) is only available.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "water_wheel"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install water_wheel

## Usage

1. Create a new S3 bucket for backup.

1. add `require "water_wheel"` to your application or ruby script.

1. Setting water_wheel gem with your AWS credential.

    ```ruby
    WaterWheel.configure do |config|
      config.provider = "AWS"
      config.aws_access_key_id = "your_access_key_id"
      config.aws_secret_access_key = "your_secret_access_key"
      config.aws_region = "your_region"
      config.aws_bucket_name = "your_bucket_name"
      config.absolute_path_on_files = ["/path/to/your/files", "/path/to/your/other/files"]
      config.absolute_path_on_directories = ["/path/to/your/directories", "/path/to/your/other/directories"]
      config.ordered_omit_path_prefixes = ["/path/prefix/to/omit"]
      config.storage_class = "STANDARD" # STANDARD, REDUCED_REDUNDANCY, STANDARD_IA...
      config.dry_run = false
    end
    ```

    * if you'd like to do a dry run, set `config.dry_run = true`


1. Run, and you will see the result.

    ```ruby
    WaterWheel::Backup.on
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shoutatani/water_wheel. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shoutatani/water_wheel/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the WaterWheel project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shoutatani/water_wheel/blob/master/CODE_OF_CONDUCT.md).
