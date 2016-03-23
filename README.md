# Phase

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'phase'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phase

## Usage

### Phasefile

In order to configure Phase, you'll need to create a `Phasefile` at the
root of your project.

**Phasefile**
```ruby
Phase.configure do |config|
  #   config.deploy.docker_repository = "mycompany/myrepo"
  #   config.deploy.docker_repository = "https://docker.mycompany.com/myrepo"
  #   config.deploy.asset_bucket = "static-assets"
end
```

#### Docker Repository - Required
This is where you tell phase where to push your built image to. Accepts
Docker Hub naming convention of "user/reponame" or your own container
host.

#### S3 Assets
Provide a bucket name and Phase will push your compiled assets to that S3
Bucket.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/phase/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
