FROM node:20-alpine

RUN apk add --no-cache python3 make g++ curl

WORKDIR /srv/app

COPY package.json package-lock.json* ./

RUN npm install && npm install pg

COPY . .

RUN npm run build

EXPOSE 1337

ENV NODE_ENV=production
CMD ["npm", "start"]
