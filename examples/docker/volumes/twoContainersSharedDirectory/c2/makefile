build:
	docker build -t c2 .

bash:
	docker run -ti --rm c2 bash

mount:
	docker run -it --mount source=testVol,target=/home/c2/shared --rm c2 bash

v:
	docker run -it -v testVol:/home/c2/shared  --rm c2 bash


