FROM ubuntu:latest
RUN useradd -ms /bin/bash -G users c2
RUN usermod -g users c2
WORKDIR /home/c2
COPY myBashCustomizations /home/c2/
RUN cat /home/c2/myBashCustomizations >> /home/c2/.bashrc
RUN chown -R c2:users /home/c2
USER c2
RUN mkdir shared


