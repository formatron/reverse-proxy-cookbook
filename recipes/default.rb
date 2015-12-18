configuration = node['formatron_reverse_proxy']['configuration']
proxies = node['formatron_reverse_proxy']['proxies']

node.default['formatron_common']['configuration'] = configuration
include_recipe 'formatron_common::default'

include_recipe 'formatron_nginx::default'

hosted_zone_name = configuration['dsl']['global']['hosted_zone_name']

proxies.each do |proxy|
  config = configuration['config'][proxy]
  ssl_config = configuration['config']['secrets']['ssl']
  hostname = "#{config['sub_domain']}.#{hosted_zone_name}"
  formatron_nginx_proxy hostname do
    port config['web_port']
    ssl_cert ssl_config['cert']
    ssl_key ssl_config['key']
    notifies :reload, 'service[nginx]', :delayed
  end
end

formatron_filebeat_prospector 'nginx_access' do
  paths [
    '/var/log/nginx/*access.log'
  ]
end

formatron_filebeat_prospector 'nginx_error' do
  paths [
    '/var/log/nginx/*error.log'
  ]
end
