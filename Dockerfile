FROM hpess/chef:latest
MAINTAINER Karl Stoney <karl.stoney@hp.com>

RUN yum -y install erlang && \
    yum -y clean all

RUN wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.0/rabbitmq-server-3.5.0-1.noarch.rpm && \
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
    yum -y install rabbitmq-server-3.5.0-1.noarch.rpm && \
    yum -y clean all && \
    rm rabbitmq-server-*.noarch.rpm

# Enable the relevant plugins
RUN /usr/sbin/rabbitmq-plugins enable --offline rabbitmq_management

# Add the service and cookbook files
COPY services/* /etc/supervisord.d/
COPY cookbooks/ /chef/cookbooks/

EXPOSE 15672 5672

ENV HPESS_ENV rabbitmq
ENV chef_node_name rabbitmq.docker.local
ENV chef_run_list rabbitmq
