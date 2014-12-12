# hpess/rabbitmq
Builds on the hpess/chef image by installing rabbitmq 

## Use
```
docker run -h rabbithost -p 5672:5672 -p 15672:15672 hpess/rabbitmq
```
Alternatively you can use the provided fig.yml:
```
fig up -d
```
The default username and password for the admin console on 15672 is 'guest' and 'guest'
