FROM ubuntu:latest
RUN useradd -ms /bin/bash -G users c1
RUN usermod -g users c1
WORKDIR /home/c1
COPY myBashCustomizations /home/c1/
RUN cat /home/c1/myBashCustomizations >> /home/c1/.bashrc
RUN chown -R c1:users /home/c1
USER c1
RUN mkdir shared


