default:
	- rm -rf dist/
	./node_modules/.bin/webpack app/index.js dist/bundle.js
	open index.html

viaConfig:
	- rm -rf dist/
	./node_modules/.bin/webpack  --display-error-details --config webpack.config.js
	open index.html
