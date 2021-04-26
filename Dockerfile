FROM ubuntu:18.04 as build

MAINTAINER SDF Ops Team <ops@stellar.org>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y gpg curl git make g++ bzip2 apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg |gpg --dearmor >/etc/apt/trusted.gpg.d/yarnpkg.gpg && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y nodejs npm

ENV NODE_ENV=prd CI=true

WORKDIR /app/src

# RUN rm -rf app/bower_components && mkdir -p .npm && npm install && \
#     ./node_modules/.bin/bower --allow-root install && ./node_modules/.bin/gulp dist
ADD package.json .
ADD bower.json .
ADD .bowerrc .
RUN npm install
RUN ./node_modules/.bin/bower --allow-root install


ADD . /app/src
RUN npm run build

FROM nginx:1.17

COPY --from=build /app/src/dist/ /usr/share/nginx/html/
