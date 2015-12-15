hostsfile_entry '127.0.0.1' do
  hostname 'sensu.mydomain.com'
  action :append
end

node.default['formatron_reverse_proxy']['configuration'] = {
  'dsl' => {
    'global' => {
      'hosted_zone_name' => 'mydomain.com'
    }
  },
  'config' => {
    'logstash' => {
      'sub_domain' => 'logstash',
      'port' => '5044'
    },
    'sensu' => {
      'sub_domain' => 'sensu',
      'checks' => {
        'mycheck' => {
          'gem' => 'cpu',
          'attributes' => {
            'command' => 'check-cpu.rb',
            'standalone' => true,
            'subscribers' => ['default'],
            'interval' => 10,
            'handlers' => ['relay']
          }
        }
      },
      'gems' => {
        'cpu' => {
          'gem' => 'sensu-plugins-cpu-checks',
          'version' => '0.0.4'
        }
      }
    },
    'test1' => {
      'sub_domain' => 'test1',
      'web_port' => 80
    },
    'test2' => {
      'sub_domain' => 'test2',
      'web_port' => 80
    },
    'secrets' => {
      'ssl' => {
        'key' => 'ssl_key',
        'cert' => 'ssl_cert'
      },
      'sensu' => {
        'rabbitmq' => {
          'vhost' => '/sensu',
          'user' => 'sensu',
          'password' => 'password'
        }
      }
    }
  }
}

node.default['formatron_sensu']['client']['subscriptions'] = ['default']

node.default['formatron_reverse_proxy']['proxies'] = %w(test1 test2)

include_recipe 'formatron_reverse_proxy::default'
