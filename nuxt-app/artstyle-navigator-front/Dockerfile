FROM node:16-bullseye

ENV APP_ROOT=/app
WORKDIR $APP_ROOT

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

COPY . .

EXPOSE 3000

CMD ["yarn", "start"]
