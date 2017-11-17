build:
	docker build -t volume_test1 .

bash:
	docker run -ti --rm volume_test1 bash

pdata:
	docker run -it \
               -v /Users/paul/s/examples/docker/volumes/singleContainerPersistentDirectory/data:/home/pshannon/persistentData \
               --rm volume_test1 bash
