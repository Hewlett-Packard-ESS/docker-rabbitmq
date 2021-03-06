![RabbitMQ](/rabbitmq.jpg?raw=true "RabbitMQ")

Builds on the hpess/chef image by installing rabbitmq, currently version 3.5.3-1.

## Use
Here's an example docker file to spin up a single rabbitmq instance:
```
rabbitmq:
  hostname: 'rabbitmq'
  image: hpess/rabbitmq
  ports: 
    - "15672:15672"
    - "5672:5672"
```
The default username and password for the admin console on 15672 is 'guest' and 'guest'

Of course you have the ability to override the rather simple configuration with your own config by adding rabbitmq.config to /storage volume.

## Traps
I've spent a silly amount of time ensuring that we trap all of the SIGTERM SIGKILL signals etc so that the instance/cluster remains stable, you can quite happily `docker restart <id>` or `docker stop <id> && docker stop <id>` and everything will continue to work well.

I've also ensured that when you stop the containers, RabbitMQ is gracefully closed down rather than brutally killed by docker.

## Clustering
This container supports clustering with some simple environment variables.  The docker-compose file below shows you how to create a three rabbit cluster:
```
rabbit1:
  image: hpess/rabbitmq 
  restart: always
  hostname: rabbit1
  ports:
    - "5672:5672"
    - "15672:15672"

rabbit2:
  image: hpess/rabbitmq 
  restart: always
  hostname: rabbit2
  links:
    - rabbit1
  environment: 
   - clustered_with=rabbit1
   - ram_node=true
  ports:
    - "5673:5672"
    - "15673:15672"

rabbit3:
  image: hpess/rabbitmq 
  restart: always
  hostname: rabbit3
  links:
    - rabbit1
    - rabbit2
  environment: 
   - clustered_with=rabbit1   
  ports:
    - "5674:5672"
```

### Erlang Cookie
The erlang cookie must be identical across all rabbit instances, you can specify one with the environment variable `erlang_cookie`, otherwise a default of 'ERLANGCOOKIE' will be used.

## License
This docker application is distributed unter the MIT License (MIT).

RabbitMQ itself is licenced under the [Mozilla Public License](https://www.rabbitmq.com/mpl.html) License.
