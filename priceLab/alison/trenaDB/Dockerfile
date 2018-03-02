FROM rocker/shiny
user root
COPY pkgs/* /home/shiny/
WORKDIR /home/shiny
ADD install.R /tmp/
RUN R -f /tmp/install.R
user shiny
CMD ["/usr/bin/shiny-server.sh"]
