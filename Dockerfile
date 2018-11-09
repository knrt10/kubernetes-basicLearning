FROM node:8

RUN npm i

ADD app.js /app.js

ENTRYPOINT [ "node", "app.js" ]
