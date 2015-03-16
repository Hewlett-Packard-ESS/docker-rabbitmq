template '/storage/rabbitmq.config' do
  source    'rabbitmq.config.erb'
  mode      '0664'
  owner     'rabbitmq'
  group     'rabbitmq'
  action    :create_if_missing
end

erlang_cookie = ENV['erlang_cookie'] || 'ERLANGCOOKIE'

file '/var/lib/rabbitmq/.erlang.cookie' do
  content   erlang_cookie
  mode      '0400'
  owner     'rabbitmq'
  group     'rabbitmq'
  action    :create
end

file '/root/.erlang.cookie' do
  content   erlang_cookie
  mode      '0400'
  owner     'root'
  group     'root'
  action    :create
end
