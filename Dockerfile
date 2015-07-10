FROM hpess/chef:master
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Latest RabbitMQ
RUN wget --quiet https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.3/rabbitmq-server-3.5.3-1.noarch.rpm && \
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
    yum -y -q install rabbitmq-server-3.5.3-1.noarch.rpm && \
    yum -y -q clean all && \
    rm rabbitmq-server-*.noarch.rpm

# Enable the relevant plugins
RUN su -c '/usr/sbin/rabbitmq-plugins --offline enable rabbitmq_management' root
RUN su -c '/usr/sbin/rabbitmq-plugins --offline enable rabbitmq_shovel' root
RUN su -c '/usr/sbin/rabbitmq-plugins --offline enable rabbitmq_shovel_management' root

# Configure the environment a little
ENV RABBITMQ_LOG_BASE /storage/log
ENV RABBITMQ_MNESIA_BASE /storage/mnesia
ENV RABBITMQ_CONFIG_FILE=/storage/rabbitmq

# Add the service and cookbook files
COPY services/* /etc/supervisord.d/
COPY preboot/* /preboot/ 
COPY cookbooks/ /chef/cookbooks/
COPY scripts/* /usr/local/bin/

EXPOSE 15672 5672

ENV HPESS_ENV rabbitmq
ENV chef_node_name rabbitmq.docker.local
ENV chef_run_list rabbitmq
