require 'rubygems'
require 'bundler/setup'
require 'spec_helper'

describe 'newrelic_plugin_agent::postgresql', :type => 'class' do
  context "When called with valid parameters" do
    let(:params) { {
      :dbhost   => 'foo',
      :port     => '123',
      :username => '123',
      :dbname   => 'foobar',
      :cfg_file => '/etc/newrelic/newrelic_plugin_agent.cfg'
    } }

    it { should contain_concat__fragment('newrelic_plugin_agent_postgresql').with(
      'target'  => '/etc/newrelic/newrelic_plugin_agent.cfg',
      'content' => /postgresql:.*host: foo.*port: 123.* user: 123.*dbname: foobar/m,
      'order'   => '03'
    ) }
  end
end
