# ---- Etapa 1: compilar el release ----
FROM elixir:1.18-alpine AS compilador
RUN apk add --no-cache build-base git
WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

# Primero sólo las dependencias, para que Docker las reutilice
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile

COPY lib lib
RUN mix release

# ---- Etapa 2: sólo ejecutar ----
FROM elixir:1.18-alpine
# tzdata para que NaiveDateTime/DateTime conozcan America/Monterrey (TZ en
# docker-compose.yml); sin esto "hoy"/"ayer" salen corridos (ver C.14).
RUN apk add --no-cache tzdata
WORKDIR /app
COPY --from=compilador /app/_build/prod/rel/funcional ./
EXPOSE 4000
CMD ["bin/funcional", "start"]
