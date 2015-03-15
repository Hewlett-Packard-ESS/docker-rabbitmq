![RabbitMQ](/rabbitmq.jpg?raw=true "RabbitMQ")

Builds on the hpess/chef image by installing rabbitmq, currently version 3.5.0-1.

## Use
Configuration is pretty limited at the moment as I haven't had time to give this container much TLC, we just needed a simple rabbitmq image for our development environment.

Here's an example docker file:
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

## License
This docker application is distributed unter the MIT License (MIT).

RabbitMQ itself is licenced under the [Mozilla Public License](https://www.rabbitmq.com/mpl.html) License.
