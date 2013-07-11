require 'rubygems'
require 'bundler/setup'
require 'spec_helper'

describe 'newrelic_plugin_agent', :type => 'class' do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'Debian' } }

  context "Whenever called on a supported host" do

    it "Includes required subclasses" do
      should include_class('newrelic_plugin_agent::config')
    end
  end

  context "When installing from pip defaults without specifying version on a supported host" do
    let(:params) { { :ensure => 'present' } }

    it {
      should contain_package('newrelic-plugin-agent').with(
        'ensure'   => 'present',
        'source'   => nil,
        'provider' => 'pip'
      )
    }
  end

  context "When installing agent with a version number from pip on a supported host" do

    ['1', '1.2', '1.2.3'].each.to_s do |version|
      let(:params) { { :ensure => version } }
      it "Should install newrelic version #{version}" do
        should contain_package('newrelic-plugin-agent').with(
          'ensure'   => version,
          'source'   => nil,
          'provider' => 'pip'
	)
      end
    end
  end

  context "If called from a gentoo host" do
    cfg_dir  = '/etc/newrelic'
    cfg_file = "#{cfg_dir}/newrelic_plugin_agent.cfg"
    let(:facts) { { :osfamily => 'Gentoo' } }

    it do
      raise_error(Puppet::Error, /Could not find init script template for Gentoo osfamily./)
    end
  end

  context "If called with valid parameters on a Debian host" do
    cfg_dir  = '/etc/newrelic'
    cfg_file = "#{cfg_dir}/newrelic_plugin_agent.cfg"
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'Debian' } }
    let(:params) { { :service_user => 'newrelic', :cfg_dir => cfg_dir, :pid_file => 'foo'} }
    it "On debian install the upstart script and start newrelic-plugin-agent" do
      should contain_file('/etc/init.d/newrelic_plugin_agent').with(
        'ensure'  => 'present',
	      'content' => /CONFIG="\/etc\/newrelic\/newrelic_plugin_agent\.cfg"/,
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '755',
        'notify'  => 'Service[newrelic_plugin_agent]'
      )
      should contain_service('newrelic_plugin_agent').with(
        'ensure'   => 'running',
        'enable'   => 'true',
        'require'  => [ 'User[newrelic]',
		                    'File[/etc/init.d/newrelic_plugin_agent]',
                        "Concat[#{cfg_file}]" ]
      ) 
    end
  end

  context "If called with valid parameters on a RedHat host" do
    cfg_dir  = '/etc/newrelic'
    cfg_file = "#{cfg_dir}/newrelic_plugin_agent.cfg"
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat' } }
    let(:params) { { :service_user => 'newrelic', :cfg_dir => cfg_dir, :pid_file => 'foo' } }

    it "On RedHat based host install the rhel init script" do
      should contain_file('/etc/init.d/newrelic_plugin_agent').with(
        'ensure'  => 'present',
	      'content' => /CONFIG_DIR="\/etc\/newrelic".*PID_FILE="foo"/m,
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '755',
        'notify'  => 'Service[newrelic_plugin_agent]'
      )
      should contain_service('newrelic_plugin_agent').with(
        'ensure'   => 'running',
        'enable'   => 'true',
        'require'  => [ 'User[newrelic]',
		                    'File[/etc/init.d/newrelic_plugin_agent]',
                        "Concat[#{cfg_file}]" ]
      ) 
    end
  end
end
