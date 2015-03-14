template '/storage/rabbitmq.config' do
  source    'rabbitmq.config.erb'
  owner     'docker'
  group     'docker'
  action    :create_if_missing
end
