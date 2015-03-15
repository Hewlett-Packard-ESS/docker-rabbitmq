template '/storage/rabbitmq.config' do
  source    'rabbitmq.config.erb'
  mode      '0664'
  owner     'rabbitmq'
  group     'rabbitmq'
  action    :create_if_missing
end

cookbook_file '/var/lib/rabbitmq/.erlang.cookie' do
  source    'erlang.cookie'
  mode      '0400'
  owner     'rabbitmq'
  group     'rabbitmq'
  action    :create
end

cookbook_file '/usr/local/bin/run-rabbitmq.sh' do
  source    'run-rabbitmq.sh'
  mode      '0755'
  owner     'rabbitmq'
  group     'rabbitmq'
  action    :create
end
