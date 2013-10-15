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
 - puppet:///modules/haproxy/haproxy If no files is matched this file will be pushed. Configuratio is the same on every machine.

        class {'haproxy':
          enabled         => true,
          running         => true,
          monitor         => true,
          static_config   => true
        }

# Example 2

In a more structured environment we can use various define to configure haproxy:

