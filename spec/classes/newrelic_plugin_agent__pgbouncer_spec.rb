require 'rubygems'
require 'bundler/setup'
require 'spec_helper'

describe 'newrelic_plugin_agent::pgbouncer', :type => 'class' do
  context "When called with valid parameters" do
    let(:params) { {
      :pghost   => 'foo',
      :port     => '123',
      :username => 'bar',
      :cfg_file => '/etc/newrelic/newrelic_plugin_agent.cfg'
    } }

    it { should contain_concat__fragment('newrelic_plugin_agent_pgbouncer').with(
      'target'  => '/etc/newrelic/newrelic_plugin_agent.cfg',
      'content' => /pgbouncer:.*host: foo.*port: 123.* user: bar/m,
      'order'   => '03'
    ) }
  end
end
