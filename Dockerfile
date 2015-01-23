FROM hpess/chef:latest
MAINTAINER Karl Stoney <karl.stoney@hp.com>

RUN yum -y install erlang logrotate && \
    yum -y clean all

RUN wget http://my.jambr.co.uk:9004/rabbitmq-server-3.4.3-1.noarch.rpm && \
    rpm --import http://my.jambr.co.uk:9004/rabbitmq-signing-key-public.asc && \
    yum -y install rabbitmq-server-*.noarch.rpm && \
    yum -y clean all && \
    rm rabbitmq-server-*.noarch.rpm

# Enable the relevant plugins
RUN echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
RUN /usr/sbin/rabbitmq-plugins enable rabbitmq_management --offline

# Add the supervisor service definition
ADD rabbitmq.service.conf /etc/supervisord.d/rabbitmq.service.conf

EXPOSE 15672 5672
