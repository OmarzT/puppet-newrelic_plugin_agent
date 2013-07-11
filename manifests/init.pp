class newrelic_plugin_agent(
  $source         = undef,
  $ensure         = 'present',
  $service_user   = 'newrelic',
  $poll_interval  = '60',
  $licence_key    = 'REPLACE_WITH_REAL_KEY',
  $agent_loglevel = 'INFO',
  $cfg_dir        = '/etc/newrelic',
  $log_dir        = '/var/log/newrelic',
  $pid_file       = '/var/run/newrelic/newrelic_plugin_agent.pid'
) {
 
  $cfg_file       = "${cfg_dir}/newrelic_plugin_agent.cfg"
  $log_file       = "${log_dir}/newrelic_plugin_agent.log"

  case $::osfamily {
    'Debian': { $template = 'newrelic_plugin_agent/newrelic_plugin_agent.deb.erb' }
    'RedHat': { $template = 'newrelic_plugin_agent/newrelic_plugin_agent.rhel.erb' }
    default:  { fail("Could not find init script template for ${::osfamily} osfamily.") }
  }
 
  include stdlib,
          newrelic_plugin_agent::config

  package{'newrelic-plugin-agent':
    ensure   => $ensure,
    source   => $source,
    provider => pip,
  }

  file {'/etc/init.d/newrelic_plugin_agent':
    ensure  => present,
    content => template($template),
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    notify  => Service[newrelic_plugin_agent],
  }

  service {'newrelic_plugin_agent':
    ensure   => running,
    enable   => true,
    require  => [ User[$service_user],
                  File["/etc/init.d/newrelic_plugin_agent"],
                  Concat[$cfg_file] ]
  }

}
