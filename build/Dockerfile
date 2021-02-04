# Comunidad ElotlMX - Esquite Docker image
# VERSION               0.2

FROM alpine
MAINTAINER Comunidad ElotlMX <contacto@elotl.mx>

RUN apk update && apk add git python3 py3-pip whois sudo curl nginx
RUN addgroup -S elotl && adduser -S elotl -G elotl -h /home/elotl -s /bin/sh

USER elotl 
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite.git
RUN cd /home/elotl/Esquite && pip3 install -r requirements.txt
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite-docker.git
RUN cp /home/elotl/Esquite-docker/build/esquite-env.yaml.template /home/elotl/Esquite/env.yaml

USER root
RUN cp /home/elotl/Esquite-docker/build/entrypoint.sh /entrypoint-esquite.sh
RUN chmod 755 /entrypoint-esquite.sh
RUN chown -R elotl:elotl /entrypoint-esquite.sh
RUN echo "elotl ALL=(ALL) NOPASSWD: /bin/chown -R elotl\:elotl /home/elotl/" >> /etc/sudoers
RUN echo "elotl ALL=(ALL) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers
RUN echo "elotl ALL=(ALL) NOPASSWD: /usr/sbin/nginx -s reload" >> /etc/sudoers
RUN mkdir -p /run/nginx/

USER elotl
ENTRYPOINT /entrypoint-esquite.sh

