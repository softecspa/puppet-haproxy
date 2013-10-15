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

## Create a Backend

Create a backend named articolo_http with options httpclose and forwardfor

        haproxy::backend {'articolo_http':
          options   => [ 'httpclose' , 'forwardfor' ],
          mode      => 'http',
        }

#### Add appsession

If we want to manage persistent session, we can define one or more appsession. This should be cookies created by the application at session start. We add in the declared backend JSESSIONID but we can add more appsession cookie

        haproxy::backend::appsession {'JSESSIONID':
          backend_name  => 'articolo_http',
          length        => 52,
          timeout       => '30m',
          options       => [ 'request-learn', 'prefix' ],
        }

#### Add servers

Now we add server that compose the backend: articolo03 and articolo04. We add some option to check server availability

        haproxy::backend::server {'articolo03':
          check           => true #(true by default),
          backend_name    => 'articolo_http',
          bind            => '192.168.1.1:80',
          inter           => '2s',
          downinter       => '1s',
          fastinter       => '1s',
          rise            => 2,
          fall            => 3,
        }

        haproxy::backend::server {'articolo04':
          check           => true #(true by default),
          backend_name    => 'articolo_http',
          bind            => '192.168.1.2:80',
          inter           => '2s',
          downinter       => '1s',
          fastinter       => '1s',
          rise            => 2,
          fall            => 3,
        }

#### Add header in request or response

Add header name X-HaProxy-Id to the request.

        haproxy::backend::add_header {'X-HaProxy-Id':
          request         => true, #(if response => true is used, header will be added on respose)
          value           => 'botolo01',
          backend_name    => 'articolo_http',
        }

Add the same header on the response
        haproxy::backend::add_header {'X-HaProxy-Id':
          response      => true, #(response and request cannot be used in conjuction)
          value         => 'botolo01',
          backend_name  => 'articolo_http',
        }

## Create a Frontend

Create a frontend that listen on 192.168.1.1:80 and 172.16.1.1:80 that use as default the backend previuosly declared

        haproxy::frontend { 'http':
          fe_name           => '' #if not defined <name> will be used,
          bind              => [ '192.168.1.1:80' , '172.16.1.1:80' ],
          default_backend   => 'articolo_http',
          options           => [ 'foo' , 'bar'],
          mode              => 'http'
        }

#### Capture header and cookie
In the defined frontend we want to capture some cookies or header that will be logged

        haproxy::frontend::capture {'JSESSIONID=':
          frontend_name => 'http':
          type          => 'cookie',
          length        => 52
        }

        haproxy::frontend::capture {'X-Backend-Id':
          frontend_name => 'http':
          type          => 'response header',
          length        => 10
        }

        haproxy::frontend::capture {'X-Varnish-Id':
          frontend_name => 'http':
          type          => 'response header',
          length        => 10
        }
