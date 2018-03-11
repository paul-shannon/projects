build:
	docker build -t shinydt -f Dockerfile .


installData:
	- mkdir -p /tmp/shinyServer/srv/appdir
	cp app.R /tmp/shinyServer/srv/appdir/
	cp placenta.draft.RData /tmp/shinyServer/srv/appdir/

run:
	docker run -d -p 3838:3838 \
              -v /tmp/shinyServer/srv:/srv/shiny-server/ \
              -v /tmp/shinyServer/varlog:/var/log/shiny-server/ \
              -v /tmp/shinyServer/varlib:/var/lib/shiny-server \
          shinydt

bash:
	docker run -it -p 3838:3838 \
              -v /tmp/shinyServer/srv:/srv/shiny-server/ \
              -v /tmp/shinyServer/varlog:/var/log/shiny-server/ \
              -v /tmp/shinyServer/varlib:/var/lib/shiny-server \
           shinydt /bin/bash
