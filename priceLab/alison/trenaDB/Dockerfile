FROM rocker/shiny
ADD install.R /tmp/
RUN R -f /tmp/install.R
CMD ["/usr/bin/shiny-server.sh"]
