# Comunidad ElotlMX - Esquite Docker image
# VERSION               0.2

FROM alpine
MAINTAINER Comunidad ElotlMX <contacto@elotl.mx>

RUN apk update && apk add git python3 py3-pip whois sudo curl
RUN addgroup -S elotl && adduser -S elotl -G elotl -h /home/elotl -s /bin/bash
RUN echo "elotl ALL=(ALL) NOPASSWD: /bin/mkdir /data/app" >> /etc/sudoers
RUN echo "elotl ALL=(ALL) NOPASSWD: /bin/chown -R elotl\:elotl /data/*" >> /etc/sudoers
USER elotl 
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite.git
RUN cd /home/elotl/Esquite && pip3 install -r requirements.txt

USER root
RUN cd /home/elotl && git clone https://github.com/ElotlMX/Esquite-docker.git
RUN mkdir /data && chown -R elotl:elotl /data

USER elotl
RUN cp /home/elotl/Esquite-docker/build/esquite-env.yaml.template /home/elotl/Esquite/env.yaml
RUN cp /home/elotl/Esquite-docker/build/entrypoint.sh /data/entrypoint.sh
RUN chmod 755 /data/entrypoint.sh

ENTRYPOINT /data/entrypoint.sh

