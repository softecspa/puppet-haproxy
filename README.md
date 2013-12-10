puppet-haproxy
==============

manage haproxy

This module can be used in two ways:
 - First: you can define, step by step, frontends, backends, acl, listen, cookie added or captured etc...
 - Second: you can use haproxy::generic_tcp:balance define and other more specialized define to balance in a simple mode various services.
 
# Example 1

We define, step by step, our environment

## Define haproxy globals

When we define haproxy class, we can specify all global options

        class {'haproxy':
          log_file          => '/var/log/haproxy/haproxy.log',
          enable_stats      => true,
          enable_hatop      => true,
          maxconn           => 2000,
          connect_timeout   => 2000,
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

## Create ACL
ACL can be created at frontend, backend and listen. Define's name of one of this must be passed as parameter.

        haproxy::acl {'acl_name':
          condition     => 'dst 192.168.1.101',
          backend_name  => 'articolo_http',
          frontend_name => '',
          listen_name   => '',
        }

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

#### Use backend
add the use_backend directive, eventually with ACL matching

        haproxy::frontend::use_backend {'articolo_http':
          frontend_name => 'http',
          backend_name  => 'articolo_http',
          if            => 'acl_name'       # resource Haproxy::Acl['acl_name'] must exists.
        }

# Example2

Using more contracted define.

## Balance a generic TCP service on port 8000
We suppose to balance 8000 port of 192.168.1.1 and 192.168.1.2 servers through 192.168.1.100 VIP address.

haproxy::generic_tcp_balance{'generic_8000':
  bind_addresses  => '192.168.1.100',
  backends        => { 'server01' => {bind => '192.168.1.1'},
                       'server02' => {bind => '192.168.1.2'}, },
  port             => '8000',
}

backends parameter accept a hash of servers. For each defined server we can use all parameter presents in haproxy::backend::server define. For example, if we want to realize a balancement active/passive we can set parameter backup to true for each passive servers

haproxy::generic_tcp_balance{'generic_8000':
  bind_addresses  => '192.168.1.100',
  backends        => { 'server01' => {bind => '192.168.1.1'},
                       'server02' => {bind => '192.168.1.2', backup => true}, },
  port             => '8000',
}

## Balance http service
we suppose to balance http service of 192.168.1.1 and 192.168.1.2 servers through 192.168.1.100 and 192.168.1.101 VIP addresses. We want to manage sticky session using JSESSIONID cookie and log JSESSIONID X-HaProxy-Id and X-Backend-Id headers. We also wat a different log file
haproxy::http_balance {'http':
  bind_addresses     => [ '192.168.1.100' , '192.168.1.101' ],
  backends           => { 'server01' => {bind => '192.168.1.1',},
                          'server02' => {bind => '192.168.1.2',},}
  appsession         => [ 'JSESSIONID' ],
  cookie_capture     => [ 'JSESSIONID=' ],
  res_header_capture => [ 'X-Varnish-Id' , 'X-Backend-Id' ],
  own_logfile        => true
}

## Balance nrpe service
We suppose to balance nrpe service of 192.168.1.1 and 192.168.1.2 servers through 192.168.1.100 VIP address. On the balancer machine nrpe should bind on 172.16.1.1 local address
haproxy::nrpe_balance {'nrpe':
  local_ip        => '172.16.1.1',
  bind_addresses  => '192.168.1.100',
  backends        => { 'server01' => {bind => '192.168.1.1'},
                       'server02' => {bind => '192.168.1.2'}, },
}

## Balance ssh service
We suppose to balance ssh service of 192.168.1.1 and 192.168.1.2 servers through 192.168.1.100 VIP address. On the balancer machine ssh should bind on 172.16.1.1 local address. We realize a active/passive balancement
haproxy::ssh_balance {'ssh':
  local_ip        => '172.16.1.1',
  bind_addresses  => '192.168.1.100',
  backends        => { 'server01' => {bind => '192.168.1.1'},
                       'server02' => {bind => '192.168.1.2', backup => true}, },
}

## Balance ftp service
We suppose to balance ftp service of 192.168.1.1 and 192.168.1.2 servers through 192.168.1.100 VIP address. We realize a active/passive balancement
haproxy::ftp_balance {'ftp':
  bind_addresses  => '192.168.1.100',
  backends        => { 'server01' => {bind => '192.168.1.1'},
                       'server02' => {bind => '192.168.1.2', backup => true}, },
}

