run:
	webpack
	open index.html

all: clean install run

clean:
	- rm -rf dist/
	- rm -rf node_modules

install:
	npm init -y
	npm install jquery --save
	npm install webpack --save
	npm install cytoscape
	npm install style-loader css-loader --save-dev




