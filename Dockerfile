# build with: docker build -t emischorr/mqtt_dimplex_gw:latest .
#  or on mac: docker buildx build --platform=linux/amd64 --no-cache -t emischorr/mqtt_dimplex_gw:latest -t emischorr/mqtt_dimplex_gw:0.2.0 .
# run with: docker run -d --rm -e MQTT_HOST=$MQTT_HOST -e MQTT_USER=$MQTT_USER -e MQTT_PW=$MQTT_PW -e DIMPLEX_HOST=$DIMPLEX_HOST emischorr/mqtt_dimplex_gw:latest start
# push with: docker push emischorr/mqtt_dimplex_gw:latest

ARG RELEASE_NAME=mqtt_dimplex_gw

ARG ELIXIR_VERSION="1.18.2"
ARG ERLANG_VERSION="27.2"
ARG ALPINE_VERSION="3.21.2"

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

# -----------------------------------------------------------------------------
ARG MIX_ENV="prod"

# build stage
FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apk add --no-cache build-base git python3 curl

# sets work dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# redeclare it as it is lost after the FROM above
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"
# needed for cross platform builds with new erlang.
# see: https://elixirforum.com/t/mix-deps-get-memory-explosion-when-doing-cross-platform-docker-build/57157/3
ENV ERL_FLAGS="+JPperf true"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile configuration files
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

# compile dependencies
RUN mix deps.compile

# copy assets
#COPY priv priv
#COPY assets assets

# Compile assets
#RUN mix assets.deploy

# compile project
COPY lib lib
RUN mix compile

# copy runtime configuration file
COPY config/runtime.exs config/

# assemble release
RUN mix release $RELEASE_NAME


# -----------------------------------------------------------------------------

# app stage
FROM ${RUNNER_IMAGE} AS runner

ARG RELEASE_NAME
ARG MIX_ENV

# install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ENV USER="elixir"

WORKDIR "/home/${USER}/app"

# Create  unprivileged user to run the release
RUN \
  addgroup \
  -g 1000 \
  -S "${USER}" \
  && adduser \
  -s /bin/sh \
  -u 1000 \
  -G "${USER}" \
  -h "/home/${USER}" \
  -D "${USER}" \
  && su "${USER}"

# run as user
USER "${USER}"

# copy release executables
COPY --from=builder --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/"${RELEASE_NAME}" ./

ENTRYPOINT ["bin/mqtt_dimplex_gw"]

CMD ["start"]
