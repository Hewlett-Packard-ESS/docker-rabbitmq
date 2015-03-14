FROM hpess/chef:latest
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Latest Erlang
RUN yum -y install http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_3_general/esl-erlang_17.4-1~centos~6_amd64.rpm && \
    yum -y clean all

# Latest RabbitMQ
RUN cd /opt && \
    wget --quiet https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.0/rabbitmq-server-generic-unix-3.5.0.tar.gz && \
    tar -xzf rabbitmq-* && \ 
    rm -f *.tar.gz && \
    mv rabbitmq* rabbitmq

# Simple Config
RUN mkdir -p /etc/rabbitmq/rabbitmq.conf.d && \ 
    echo "NODENAME=rabbit@localhost" >> /etc/rabbitmq/rabbitmq.conf.d/hostname.conf
ENV PATH /opt/rabbitmq/sbin:$PATH 

# Enable the relevant plugins
RUN su -c '/opt/rabbitmq/sbin/rabbitmq-plugins enable --offline rabbitmq_management' root

# Add the service and cookbook files
COPY services/* /etc/supervisord.d/
COPY cookbooks/ /chef/cookbooks/

EXPOSE 15672 5672

ENV HPESS_ENV rabbitmq
ENV chef_node_name rabbitmq.docker.local
ENV chef_run_list rabbitmq
