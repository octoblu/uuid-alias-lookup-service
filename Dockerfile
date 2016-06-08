FROM node:5-onbuild
MAINTAINER Octoblu <docker@octoblu.com>

EXPOSE 80

ENV NPM_CONFIG_LOGLEVEL error

CMD [ "node", "command.js" ]
