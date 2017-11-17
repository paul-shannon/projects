build:
	docker build -t c1 .

bash:
	docker run -ti --rm c1 bash


mount:
	docker run -it --mount source=testVol,target=/shared --rm c1 bash

v:
	docker run -it -v testVol:/home/c1/shared  --rm c1 bash
