puppet-haproxy
==============

manage haproxy

This module can be used in two ways:
 - First: you push a static configuration file using static_config. All configuration, frontend, backend etc are specified in this file.
 - Second: you can use params of classes and his defines to construct a conf file with fragments.
 
# Example 1

In this case, we install haproxy on node botolo01 (that is part of cluster named botolo). We put the static configuration file under one of these files:
 - puppet:///modules/haproxy/haproxy_botolo01 (customized configuration for the single node botolo01)
 - puppet:///modules/haproxy/haproxy_botolo   (for instance, if we have a HA configuration managed with heartbeat, we use the same configuration for every node in the cluster)
 - puppet:///modules/haproxy/haproxy If no files is matched this file will be pushed. Configuration is the same on every machine.

        class {'haproxy':
          enabled         => true,
          running         => true, # (true by default)
          monitor         => true, # (false by default)
          static_config   => true  # (true by default)
        }

# Example 2

In a more structured environment we can use various define to configure haproxy:


## Define haproxy globals

When we define haproxy class, we can specify all global options

        class {'haproxy':
          log_file          => '/var/log/haproxy/haproxy.log',
          syslog_facility   => 'local1',
          enable_stats      => true,
          enable_hatop      => true,
          maxconn           => 2000,
          contimeout        => 5000,
          clitimeout        => 50000,
          srvtimeout        => 50000,
          mode              => http,
          options           => [ 'httplogs', 'redispatch' ],
          enable_stats      => true,
          stats_user        => 'haproxystats',
          stats_pass        => 'XXXXXXXX',
        }

 - log_file: false by Default. It may also be a path to the logfile. if this params is a path, syslog_facility become mandatory, this module also enable a syslog facility and redirect correct logs.
 - enable_stats: if true, stats will be enabled and protected with stats_user:stats_pass
 - Other params are described in HaProxy official documentation

