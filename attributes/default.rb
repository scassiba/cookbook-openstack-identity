# encoding: UTF-8
#
# Cookbook Name:: openstack-identity
# Recipe:: default
#
# Copyright 2012-2013, AT&T Services, Inc.
# Copyright 2013, Opscode, Inc.
# Copyright 2013, IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['identity']['custom_template_banner'] = "
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
"

# Set the endpoints for the identity service to allow all other cookbooks to
# access and use them
%w(public internal admin).each do |ep_type|
  # openstack identity service endpoints (used by users and services)
  default['openstack']['endpoints'][ep_type]['identity']['host'] = '127.0.0.1'
  default['openstack']['endpoints'][ep_type]['identity']['scheme'] = 'http'
  default['openstack']['endpoints'][ep_type]['identity']['path'] = '/v2.0'
end
default['openstack']['endpoints']['public']['identity']['port'] = 5000
default['openstack']['endpoints']['internal']['identity']['port'] = 5000
default['openstack']['endpoints']['admin']['identity']['port'] = 35357

default['openstack']['bind_service']['main']['identity']['host'] = '127.0.0.1'
default['openstack']['bind_service']['main']['identity']['port'] = 5000
default['openstack']['bind_service']['admin']['identity']['host'] = '127.0.0.1'
default['openstack']['bind_service']['admin']['identity']['port'] = 35357

default['openstack']['identity']['catalog']['backend'] = 'sql'
default['openstack']['identity']['token']['backend'] = 'sql'
# Adding these as blank
# this needs to be here for the initial deep-merge to work
default['credentials']['EC2']['admin']['access'] = ''
default['credentials']['EC2']['admin']['secret'] = ''

default['openstack']['identity']['verbose'] = 'False'
default['openstack']['identity']['debug'] = 'False'

# Keystone service startup delay, in seconds
default['openstack']['identity']['start_delay'] = 10

# Specify a location to retrieve keystone-paste.ini from
# which can either be a remote url using http:// or a
# local path to a file using file:// which would generally
# be a distribution file - if this option is left nil then
# the templated version distributed with this cookbook
# will be used (keystone-paste.ini.erb)
default['openstack']['identity']['pastefile_url'] = nil

# This specify the pipeline of the keystone public API,
# all Identity public API requests will be processed by the order of the pipeline.
# this value will be used in the templated version of keystone-paste.ini
# The last item in this pipeline must be public_service or an equivalent
# application. It cannot be a filter.
default['openstack']['identity']['pipeline']['public_api'] = 'sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension user_crud_extension public_service'
# This specify the pipeline of the keystone admin API,
# all Identity admin API requests will be processed by the order of the pipeline.
# this value will be used in the templated version of keystone-paste.ini
# The last item in this pipeline must be admin_service or an equivalent
# application. It cannot be a filter.
default['openstack']['identity']['pipeline']['admin_api'] = 'sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension s3_extension crud_extension admin_service'
# This specify the pipeline of the keystone V3 API,
# all Identity V3 API requests will be processed by the order of the pipeline.
# this value will be used in the templated version of keystone-paste.ini
# The last item in this pipeline must be service_v3 or an equivalent
# application. It cannot be a filter.
default['openstack']['identity']['pipeline']['api_v3'] = 'sizelimit url_normalize request_id build_auth_context token_auth admin_token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3'

default['openstack']['identity']['region'] = node['openstack']['region']

# Logging stuff
default['openstack']['identity']['syslog']['use'] = false
default['openstack']['identity']['syslog']['facility'] = 'LOG_LOCAL2'
default['openstack']['identity']['syslog']['config_facility'] = 'local2'

default['openstack']['identity']['admin_user'] = 'admin'
default['openstack']['identity']['admin_tenant_name'] = 'admin'

default['openstack']['identity']['users'] = {
  default['openstack']['identity']['admin_user'] => {
    'default_tenant' => default['openstack']['identity']['admin_tenant_name'],
    'roles' => {
      'admin' => ['admin'],
      'service' => ['admin']
    }
  }
}

# SSL Options
# Specify whether to enable SSL for Keystone API endpoint
default['openstack']['identity']['ssl']['enabled'] = false
# Specify server whether to enforce client certificate requirement
default['openstack']['identity']['ssl']['cert_required'] = false
# SSL certificate, keyfile and CA certficate file locations
default['openstack']['identity']['ssl']['basedir'] = '/etc/keystone/ssl'
# Path of the cert file for SSL.
# Protocol for SSL (Apache)
default['openstack']['identity']['ssl']['protocol'] = 'All -SSLv2 -SSLv3'
# Which ciphers to use with the SSL/TLS protocol (Apache)
# Example: 'RSA:HIGH:MEDIUM:!LOW:!kEDH:!aNULL:!ADH:!eNULL:!EXP:!SSLv2:!SEED:!CAMELLIA:!PSK!RC4:!RC4-MD5:!RC4-SHA'
default['openstack']['identity']['ssl']['ciphers'] = nil

# PKI signing. Corresponds to the [signing] section of keystone.conf
# Note this section is only written if node['openstack']['auth']['strategy'] == 'pki'
default['openstack']['identity']['signing']['basedir'] = '/etc/keystone/ssl'

# Fernet keys. Note this section is only written if
# node['openstack']['auth']['strategy'] == 'fernet'
# Fernet keys to read from databags/vaults. This should be changed in the
# environment when rotating keys (with the defaults below, the items
# 'fernet_key0' and 'fernet_key1' will be read from the databag/vault
# 'keystone).
# For more information please read:
# http://docs.openstack.org/admin-guide-cloud/keystone_fernet_token_faq.html
default['openstack']['identity']['fernet']['keys'] = [0, 1]

# The authorization configuration options
# The external (REMOTE_USER) auth plugin module. (String value)
default['openstack']['identity']['auth']['external'] = 'keystone.auth.plugins.external.DefaultDomain'
# Default auth methods. (List value)
default['openstack']['identity']['auth']['methods'] = 'external, password, token, oauth1'

# Token flushing cronjob
default['openstack']['identity']['token_flush_cron']['log_file'] = '/var/log/keystone/token-flush.log'
default['openstack']['identity']['token_flush_cron']['hour'] = '*'
default['openstack']['identity']['token_flush_cron']['minute'] = '0'
default['openstack']['identity']['token_flush_cron']['day'] = '*'
default['openstack']['identity']['token_flush_cron']['weekday'] = '*'
default['openstack']['identity']['token_flush_cron']['enabled'] = true

default['openstack']['identity']['identity']['domain_config_dir'] = '/etc/keystone/domains'
default['openstack']['identity']['signing']['basedir'] = '/etc/keystone/ssl'

default['openstack']['identity']['signing']['certfile'] = "#{node['openstack']['identity']['signing']['basedir']}/certs/signing_cert.pem"
default['openstack']['identity']['signing']['keyfile'] = "#{node['openstack']['identity']['signing']['basedir']}/private/signing_key.pem"
default['openstack']['identity']['signing']['ca_certs'] = "#{node['openstack']['identity']['signing']['basedir']}/certs/ca.pem"
# Misc option support
# Allow additional strings to be added to keystone.conf
# For example:  ['# Comment', 'key=value']
default['openstack']['identity']['misc_keystone'] = []

# SSL Options
# Specify whether to enable SSL for Keystone API endpoint
default['openstack']['identity']['ssl']['enabled'] = false
# Specify server whether to enforce client certificate requirement
default['openstack']['identity']['ssl']['cert_required'] = false
# SSL certificate, keyfile and CA certficate file locations
default['openstack']['identity']['ssl']['basedir'] = '/etc/keystone/ssl'
# Path of the cert file for SSL.
default['openstack']['identity']['ssl']['certfile'] = "#{node['openstack']['identity']['ssl']['basedir']}/certs/sslcert.pem"
# Path of the keyfile for SSL.
default['openstack']['identity']['ssl']['keyfile'] = "#{node['openstack']['identity']['ssl']['basedir']}/private/sslkey.pem"
# Path of the CA cert file for SSL.
default['openstack']['identity']['ssl']['ca_certs'] = "#{node['openstack']['identity']['ssl']['basedir']}/certs/sslca.pem"
# Path of the CA cert files for SSL (Apache)
default['openstack']['identity']['ssl']['ca_certs_path'] = "#{node['openstack']['identity']['ssl']['basedir']}/certs/"
# Protocol for SSL (Apache)
default['openstack']['identity']['ssl']['protocol'] = 'All -SSLv2 -SSLv3'
# Which ciphers to use with the SSL/TLS protocol (Apache)
# Example: 'RSA:HIGH:MEDIUM:!LOW:!kEDH:!aNULL:!ADH:!eNULL:!EXP:!SSLv2:!SEED:!CAMELLIA:!PSK!RC4:!RC4-MD5:!RC4-SHA'
default['openstack']['identity']['ssl']['ciphers'] = nil

# platform defaults
case platform_family
when 'fedora', 'rhel' # :pragma-foodcritic: ~FC024 - won't fix this
  default['openstack']['identity']['user'] = 'keystone'
  default['openstack']['identity']['group'] = 'keystone'
  default['openstack']['identity']['platform'] = {
    'memcache_python_packages' => ['python-memcached'],
    'keystone_packages' => ['openstack-keystone'],
    'keystone_client_packages' => ['python-keystoneclient'],
    'keystone_service' => 'openstack-keystone',
    'keystone_process_name' => 'keystone-all',
    'keystone_wsgi_file' => '/usr/share/keystone/keystone.wsgi',
    'package_options' => ''
  }
when 'debian'
  default['openstack']['identity']['user'] = 'keystone'
  default['openstack']['identity']['group'] = 'keystone'
  default['openstack']['identity']['platform'] = {
    'memcache_python_packages' => ['python-memcache'],
    'keystone_packages' => ['keystone'],
    'keystone_client_packages' => ['python-keystoneclient'],
    'keystone_service' => 'keystone',
    'keystone_process_name' => 'keystone-all',
    'keystone_wsgi_file' => '/usr/share/keystone/wsgi.py',
    'package_options' => "-o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-confdef'"
  }
end

# Array of bare options for openrc (e.g. 'option=value')
default['openstack']['misc_openrc'] = nil

# openrc location and owner
default['openstack']['openrc']['path'] = '/root'
default['openstack']['openrc']['file'] = 'openrc'
default['openstack']['openrc']['user'] = 'root'
default['openstack']['openrc']['group'] = 'root'
default['openstack']['openrc']['file_mode'] = '0600'
default['openstack']['openrc']['path_mode'] = '0700'
