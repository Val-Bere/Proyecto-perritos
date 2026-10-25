FROM elixir:1.17-alpine
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

# primero solo las dependencias (así Docker las guarda en caché)
COPY mix.exs mix.lock* ./
RUN mix deps.get

COPY lib lib
COPY test test
RUN mix compile

ENV PORT=4000
EXPOSE 4000
CMD ["mix", "run", "--no-halt"]
