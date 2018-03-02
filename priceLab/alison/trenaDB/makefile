build:
	docker build -t shinydt -f Dockerfile .


run:
	docker run --rm -p 3838:3838 \
              -v /tmp/:/srv/shiny-server/ \
              -v /tmp/varlog:/var/log/shiny-server/ \
              -v /tmp/varlib:/var/lib/shiny-server \
          shinydt

run2:
	docker run --rm -p 4838:3838 \
              -v $(CURDIR)/shinyruntime/srv/:/srv/shiny-server/ \
              -v $(CURDIR)/shinyruntime/varlog:/var/log/shiny-server/ \
              -v $(CURDIR)/shinyruntime/varlib:/var/lib/shiny-server \
          shinydt


bash:
	docker run --rm -p 3838:3838 \
              -v /tmp/:/srv/shiny-server/ \
              -v /tmp/:/var/log/shiny-server/ shinydt bash

test:
	echo $(CURDIR)

