FROM hpess/chef:latest
MAINTAINER Karl Stoney <karl.stoney@hp.com>

ENV https_proxy=http://proxy.sdc.hp.com:8080
ENV http_proxy=http://proxy.sdc.hp.com:8080
# Latest RabbitMQ
RUN wget --quiet https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.0/rabbitmq-server-3.5.0-1.noarch.rpm && \
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
    yum -y install rabbitmq-server-3.5.0-1.noarch.rpm && \
    yum -y clean all && \
    rm rabbitmq-server-*.noarch.rpm

# Enable the relevant plugins
RUN su -c '/usr/sbin/rabbitmq-plugins --offline enable rabbitmq_mqtt rabbitmq_stomp rabbitmq_management rabbitmq_management_agent rabbitmq_management_visualiser rabbitmq_federation rabbitmq_federation_management sockjs' root

# Configure the environment a little
ENV RABBITMQ_LOG_BASE /storage/log
ENV RABBITMQ_MNESIA_BASE /storage/mnesia
ENV RABBITMQ_CONFIG_FILE=/storage/rabbitmq

# Add the service and cookbook files
COPY services/* /etc/supervisord.d/
COPY preboot/* /preboot/ 
COPY cookbooks/ /chef/cookbooks/
COPY run-rabbitmq.sh /usr/local/bin/run-rabbitmq.sh

EXPOSE 15672 5672

ENV HPESS_ENV rabbitmq
ENV chef_node_name rabbitmq.docker.local
ENV chef_run_list rabbitmq
