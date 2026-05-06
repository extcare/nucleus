FROM node:8

# Debian Stretch reached EOL; redirect to archive mirrors
RUN sed -i \
    's|deb.debian.org/debian|archive.debian.org/debian|g; s|security.debian.org/debian-security|archive.debian.org/debian-security|g; /stretch-updates/d' \
    /etc/apt/sources.list && \
    apt-get update && apt-get install -y createrepo dpkg-dev apt-utils gnupg2 gzip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/service

# Copy PJ, changes should invalidate entire image
COPY package.json yarn.lock /opt/service/


# Copy commong typings
COPY typings /opt/service/typings

# Copy TS configs
COPY tsconfig* /opt/service/

# Build backend
COPY src /opt/service/src

# Build Frontend

COPY public /opt/service/public
COPY webpack.*.js postcss.config.js README.md /opt/service/

# Install dependencies
RUN yarn --cache-folder ../ycache && yarn build:server && yarn build:fe:prod && yarn --production --cache-folder ../ycache && rm -rf ../ycache

EXPOSE 8080

ENTRYPOINT ["npm", "run", "start:server:prod", "--"]