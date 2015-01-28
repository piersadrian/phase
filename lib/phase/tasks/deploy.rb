# require "phase/dsl"
require 'colorize'

task deploy: "deploy:all"

namespace :deploy do
  task all: [
    :verify_environment,
    :set_version,
    :build_assets,
    :record_deployment
    # :trigger_docker_build
    # :deploy_to_target_servers_in_sequence
  ]

  task verify_environment: :environment do
    ::Deploy.raise_on_incorrect_branch!
    ::Deploy.raise_on_dirty_index!
  end

  task set_version: :environment do
    ::Deploy.log "Last release was version #{ ::Deploy.current_version.magenta }"
    next_version_num = ::Deploy.ask "New version number: "
    ::Deploy.write_version(next_version_num)
  end

  task build_assets: :environment do
    ::Deploy.precompile_assets
    ::Deploy.sync_assets
  end

  task record_deployment: :environment do
    ::Deploy.stage_changes!
    ::Deploy.commit_deployment!
  end
end


module Deploy
  class << self
    VERSION_LOCKFILE_PATH = "VERSION"
    VERSION_RBFILE_PATH   = "lib/harpoon/version.rb"

    def ask(str)
      print "[deploy] ".green + str
      STDIN.gets.chomp
    end

    def commit_deployment!
      system("git commit -m 'Preparing to release v#{ ::Deploy.current_version }' -e")
    end

    def current_version
      ::File.open(VERSION_LOCKFILE_PATH) do |file|
        file.read.chomp
      end
    end

    def environment
      ARGV[1] || "staging"
    end

    def fail(str)
      abort("[deploy] error: ".red + str)
    end

    def log(str)
      puts "[deploy] ".green + str
    end

    def precompile_assets
      system("RAILS_GROUPS=assets RAILS_ENV=#{ ::Deploy.environment } rake assets:precompile")
    end

    def raise_on_dirty_index!
      unless system('git diff-index --quiet --cached HEAD')
        fail "other changes are already staged. Commit them or 'git reset HEAD' first."
      end
    end

    def raise_on_incorrect_branch!
      current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      needed_branch  = ::Deploy.environment == "staging" ? "develop" : "master"

      if current_branch != needed_branch
        fail "your current branch is #{current_branch}. Switch to #{needed_branch}."
      end
    end

    def stage_changes!
      files = [
        ::Rails.root.join("public", ::Rails.application.config.assets.prefix, "manifest*.json"),
        ::Rails.root.join(::Deploy::VERSION_LOCKFILE_PATH),
        ::Rails.root.join(::Deploy::VERSION_RBFILE_PATH)
      ]

      system("git add #{ files.join(" ") }")
    end

    def sync_assets
      system("RAILS_GROUPS=assets RAILS_ENV=#{ ::Deploy.environment } rake assets:sync")
    end

    def write_version(version_num)
      ::File.open(VERSION_LOCKFILE_PATH, 'w') do |file|
        file.write(version_num)
      end

      ::File.open(VERSION_RBFILE_PATH, 'w') do |file|
        file.write <<-VERSION.strip_heredoc
        module Harpoon
          VERSION = "#{version_num}"
        end
        VERSION
      end
    end
  end
end
