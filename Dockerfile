FROM ubuntu:22.04
WORKDIR /sentinel
ADD Gemfile .
RUN apt update && \ 
    apt install -y vim libgeoip-dev autoconf libmaxminddb-dev curl sudo ruby-dev build-essential rsyslog libtool tcpdump net-tools ufw systemctl && \
    gem install bundler && \
    bundle install && \
    apt remove -y build-essential curl && \
    apt autoremove -y && \
    apt clean && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --shell /bin/bash sentinel
RUN echo 'sentinel:yourpassword' | chpasswd
RUN usermod -a -G adm,syslog sentinel
RUN echo 'sentinel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ADD . .
RUN mkdir /sentinel/rsyslog && chown -R sentinel.sentinel /sentinel
USER sentinel
EXPOSE 5142/tcp
EXPOSE 5142/udp
COPY entrypoint.sh /sentinel/
RUN sed -i 's/\r$//' /sentinel/entrypoint.sh
RUN chmod 750 /sentinel/entrypoint.sh
CMD ["/sentinel/entrypoint.sh"]
