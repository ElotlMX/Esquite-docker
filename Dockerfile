# Comunidad ElotlMX - Esquite Docker image
# VERSION               0.1

FROM debian
MAINTAINER Javier Santillan <jusafing@protonmail.com>

RUN apt-get update
RUN apt-get update
RUN apt-get install -y git nginx python3 python3-pip vim net-tools htop whois sudo
RUN useradd -m -s /bin/bash -d /home/elotl elotl
RUN echo "elotl ALL=(ALL) NOPASSWD: /usr/sbin/service nginx restart" >> /etc/sudoers
USER elotl 
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite.git
RUN cd /home/elotl/Esquite && pip3 install -r requirements.txt

USER root
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite-docker.git
RUN cp /home/elotl/Esquite-docker/build/nginx-esquite.conf.template /etc/nginx/sites-enabled/default
RUN touch /etc/nginx/users.pwd

USER elotl
RUN cp /home/elotl/Esquite-docker/build/env.yaml.template /home/elotl/Esquite/env.yaml
RUN cp /home/elotl/Esquite-docker/build/entrypoint.sh /home/elotl/entrypoint.sh
RUN chmod 755 /home/elotl/entrypoint.sh

ENTRYPOINT /home/elotl/entrypoint.sh

