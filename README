= Module HaProxy

This module manages installation and configuration of HaProxy. You can use the module in various mode.

== Use of defines haproxy::cluster_balance and haproxy::balanced
The easiest way to use this module is to balance a whole cluster. Balanced cluster's machines will export their configuration, balancer will import these resources.
Suppose to have this scenario:

 * cluster foo is a cluster composed by foo01 and foo02.
 * cluster bar is a active/passive HA balancer system.

We want to balance every services on foo through bar. Except for http we will use a active/passive balancement method, we suppose that foo01 is the active node, foo02 (and every other machine in cluster), will be the backup.
Cluster_balance and balanced defines don't manage http balancement, to balance http service we'll use http_balance and http_balanced defines that works in the same way of cluster_balance and balanced defines.

  node clusterfoo {

    haproxy::balanced_http {'bar':
      balanced_interface  => 'ethX',
    }

    haproxy::balanced {'bar':
      balanced_interface  => ethX,
      active_node         => 'foo01'
    }

  }

  node foo01 inherits clusterfoo {}
  node foo02 inherits clusterfoo {}

These resources will export haproxy configuration fragments relative to node foo01 and foo02 for each balanced service. In this example we suppose that foo01 and foo02 have their public address (or private, if you want to balance on backplane addesses) on ethX interface. foo01 is the active node.
On balancer's side:

  node clusterbar {

    $vip = 'x.x.x.x' #(it can be an array of addresses)

    haproxy::http_balance {'clusterfoo_http':
      bind_addresses      => $vip,
    }

    haproxy::cluster_balance {'foo':
      vip             => $vip,
      local_interface => 'ethX',
    }

  }

Note the used resource names. We put balanced cluster name. This is a convention. We specify also a <local_interface> parameter in cluster_balance define. This parameter identify interface used to bind local services on the balancer servers. For example: while bar01 and bar02 balance ssh service, bar01 and bar02 also need to have their ssh service reachable. Address present in ethX interface will be used to bind local ssh service.

== Balance a single service
In the same way of cluster_balance and balanced defines, we can balance a single service. We can use various define on backend's side:
 * balanced_ftp
 * balanced_http
 * balanced_imap
 * balanced_imaps
 * balanced_ispconfig
 * balanced_nrpe
 * balanced_pop
 * balanced_pops
 * balanced_smtp
 * balanced_ssh
And the relative define on balancer's side:
 * ftp_balance
 * generic_tcp_balance
 * http_balance
 * nrpe_balance
 * smtp_balance
 * ssh_balance

For example, if we want to balance only ssh service.
On backend side:
  node clusterfoo {

    balanced_ssh { 'bar':
      balanced_interface => 'ethX',
      active_node        => 'foo01'
    }

  }
on balancer side:
  node clusterbar {
    ssh_balance { 'clusterfoo_ssh':
      local_ip        => 'x.x.x.x',
      bind_addresses  => $vip
    }
  }
Please note that ssh_balance resource name is again composed by cluster${balanced_cluster_name}_${service_name}

== Use of generic_tcp_balance
In the previously example note that on balancer side don't exists a define for every service but exists a define called generic_tcp_balance. This define is used on balancer side to balance a generic service, for example pop.
We suppose that we want to balance pop service. On backend side:

  node clusterfoo {

    balanced_pop { 'bar':
      balanced_interface => 'ethX',
      active_node        => 'foo01'
    }

  }
On balancer side we use generic_tcp_balance:
  node clusterbar {
    generic_tcp_balance { 'clusterfoo_pop':
      bind_addresses  => $vip,
      port            => '110'
    }
  }

Note that generic_tcp_balance define's name is again in the form cluster${balanced_cluster_name}_${service_name}

== Configure only balancer's node, without exported resources
In all above examples we export haproxy backends configurations through exported resource using clustername and servicename as conventions to tag exported resources and to retrieve it. If we want to have a more complex balancer configuration we can use a series of defines used to configure only the balancer nodes.
We suppose that we want to balance http for cluster foo

=== Step 1: create a backend:
  haproxy::backend {'http':
    options   => [ 'httpclose' , 'forwardfor' ],
    mode      => 'http',
  }

see backend define documentation for parameter's explaination

=== Step 2: add server to above created backed
  haproxy::backend::server {'foo01':
    backend_name    => 'http',
    bind            => 'x.x.x.x:80',
  }

  haproxy::backend::server {'foo02':
    backend_name    => 'http',
    bind            => 'y.y.y.y:80',
  }
Please note that backend_name parameter is the name of backend resource prevoiusly defined.

=== Step 3: optionaly add appsession or header (see haproxy official documentation for more explainations)

  haproxy::backend::add_header {'X-HaProxy-Id':
    request         => true, #(if response => true is used, header will be added on respose)
    value           => $hostname,
    backend_name    => 'http',
  }

  haproxy::backend::appsession {'JSESSIONID':
    backend_name  => 'http',
    length        => 52,
    timeout       => '30m',
    options       => [ 'request-learn', 'prefix' ],
  }

Please note that in above define backend_name parameter is always the name of backend resource defined in step 1

=== Step 4: create a frontend
  haproxy::frontend { 'frontend_http':
    bind              => [ 'x.x.x.x':80' , 'y.y.y.y:80' ],
    default_backend   => 'http',
    options           => [ 'foo' , 'bar'],
    mode              => 'http'
  }
Plese note that default_backend parameter is again the name of backend resource defined in step 1.

=== Use more compact code
We can configure balancer's node without exported resource also using ${service_name}_balance define. These define collect configuration exported by backend nodes, bu we can also set backend manually:
  haproxy::http_balance {'http_balance':
    bind_addresses     => [ 'x.x.x.x' , 'y.y.y.y' ],
    backends           => { 'foo01' => {bind => 'z.z.z.z',},
                            'foo02' => {bind => 'k.k.k.k',},}
    appsession         => [ 'JSESSIONID' ],
    cookie_capture     => [ 'JSESSIONID=' ],
    res_header_capture => [ 'X-Varnish-Id' , 'X-Backend-Id' ],
  }

See http_balance documentation to see explaination of used parameters.
