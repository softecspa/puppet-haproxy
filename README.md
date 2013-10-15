puppet-haproxy
==============

manage haproxy

This module can be used in two ways:
 - First: you push a static configuration file using static_config. All configuration, frontend, backend etc are specified in this file.
 - Second: you can use params of classes and his defines to construct a conf file with fragments.
 
Example 1
