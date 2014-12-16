require 'spec_helper'
require 'phase/dsl'
require 'fog'

describe ::Phase::DSL do
  describe "looking up bastion IPs" do
    let(:dns_name) { "server1.orcahealth.com" }
    let(:fog_server) { ::Fog::Compute::AWS.new(region: "us-east-1").servers.new(dns_name: dns_name) }
    let(:server) { ::Phase::Adapters::AWS::Server.new(fog_server) }

    it "should query AWS for servers" do
      server_api = object_double("Phase::Adapters::AWS::Server", where: [server]).as_stubbed_const

      on_role("ssh") {}

      expect(server_api).to have_received(:where).with(role: "ssh")
    end
  end
end
