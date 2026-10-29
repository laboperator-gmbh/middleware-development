FROM node:24-alpine as base

ENV NODE_ENV=production
ENV NODE_OPTIONS=--max_old_space_size=4096

RUN mkdir /middleware
WORKDIR /middleware

################################
# Stage: Builder
################################
FROM base as builder

RUN apk --update --no-cache add \
    build-base \
    git \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apk/*

COPY .yarnrc.yml package.json yarn.lock ./
RUN corepack enable \
 && NODE_ENV=development yarn install --immutable

COPY . /middleware
WORKDIR /middleware

RUN mkdir -p bin \
 && cp ./node_modules/middleware-development/docker-entrypoint.sh ./ \
 && cp ./node_modules/middleware-development/bin/server ./bin/server

RUN yarn middleware compile

# Remove folders not needed in resulting image
RUN rm -rf node_modules src

################################
# Stage: Final (production/test)
################################
FROM base

# https://nodejs.org/api/cli.html#cli_node_extra_ca_certs_file
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    git \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /var/cache/apk/*

COPY --from=builder /middleware /middleware

# Reinstall runtime dependencies
RUN corepack enable \
 && yarn install --immutable \
 && yarn cache clean --all

# FIX: https://github.com/nodejs/docker-node/issues/1776
RUN find /usr/local/include/node/openssl/archs -mindepth 1 ! -regex '.*linux-x86_64.*' -delete

ENTRYPOINT ["sh", "docker-entrypoint.sh"]
CMD ["node", "./bin/server"]
