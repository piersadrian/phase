require "terminal-table"
require "active_support"
require "progressbar"
require "colorize"
require "fog"
require "capistrano/dsl"

require "dotenv"
::Dotenv.load if defined?(::Dotenv)

require "phase/version"

module Phase
end
