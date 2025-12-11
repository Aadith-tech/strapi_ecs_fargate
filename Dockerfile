FROM node:20-alpine

RUN apk add --no-cache python3 make g++

WORKDIR /myStrapi

COPY package.json package-lock.json* ./

RUN npm install && npm install pg

COPY . .

EXPOSE 1337

CMD ["npm", "run", "develop"]

