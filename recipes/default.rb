configuration = node['formatron_reverse_proxy']['configuration']
proxies = node['formatron_reverse_proxy']['proxies']

node.default['formatron_filebeat']['prospectors'] = [{
  paths: [
    '/var/log/syslog'
  ],
  document_type: 'syslog'
}, {
  paths: [
    '/var/log/nginx/*access.log'
  ],
  document_type: 'nginx_access'
}, {
  paths: [
    '/var/log/nginx/*error.log'
  ],
  document_type: 'nginx_error'
}]

node.default['formatron_common']['configuration'] = configuration
include_recipe 'formatron_common::default'

include_recipe 'formatron_nginx::default'

hosted_zone_name = configuration['dsl']['global']['hosted_zone_name']

proxies.each do |proxy|
  config = configuration['config'][proxy]
  secrets = configuration['config']['secrets'][proxy]
  hostname = "#{config['sub_domain']}.#{hosted_zone_name}"
  formatron_nginx_proxy hostname do
    port config['web_port']
    ssl_cert secrets['ssl']['cert']
    ssl_key secrets['ssl']['key']
    notifies :reload, 'service[nginx]', :delayed
  end
end
