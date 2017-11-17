FROM ubuntu:latest
RUN useradd -ms /bin/bash pshannon
WORKDIR /home/pshannon
COPY myBashCustomizations /home/pshannon/
RUN cat /home/pshannon/myBashCustomizations >> /home/pshannon/.bashrc
RUN chown -R pshannon:users /home/pshannon
USER pshannon


