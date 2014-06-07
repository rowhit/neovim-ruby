require "rubygems"
require "bundler/setup"
require "neovim"
require "timeout"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

RSpec.shared_examples :remote => true do
  let!(:client) do
    Timeout.timeout(1) do
      begin
        Neovim::Client.new("/tmp/neovim.sock").command("cq")
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        retry
      end

      begin
        Neovim::Client.new("/tmp/neovim.sock")
      rescue Errno::ENOENT, Errno::ECONNREFUSED, EOFError
        retry
      end
    end
  end
end
