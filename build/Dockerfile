# Comunidad ElotlMX - Esquite Docker image
# VERSION               0.2

FROM alpine
MAINTAINER Comunidad ElotlMX <contacto@elotl.mx>

RUN apk update && apk add git nginx python3 py3-pip whois sudo
RUN addgroup -S elotl && adduser -S elotl -G elotl -h /home/elotl -s /bin/bash
RUN echo "elotl ALL=(ALL) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers
RUN echo "elotl ALL=(ALL) NOPASSWD: /usr/sbin/nginx -s reload" >> /etc/sudoers
USER elotl 
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite.git
RUN cd /home/elotl/Esquite && pip3 install -r requirements.txt

USER root
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite-docker.git
RUN cp /home/elotl/Esquite-docker/build/nginx-esquite.conf.template /etc/nginx/conf.d/default.conf
RUN mkdir -p /run/nginx/

USER elotl
RUN cp /home/elotl/Esquite-docker/build/env.yaml.template /home/elotl/Esquite/env.yaml
RUN cp /home/elotl/Esquite-docker/build/entrypoint.sh /home/elotl/entrypoint.sh
RUN chmod 755 /home/elotl/entrypoint.sh

ENTRYPOINT /home/elotl/entrypoint.sh
