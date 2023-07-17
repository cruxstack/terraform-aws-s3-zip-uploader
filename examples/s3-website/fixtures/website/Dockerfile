FROM node:18 as build

WORKDIR /opt/app

COPY . .

# additional build steps here (e.g. npm install)

# ------------------------------------------------------------------ package ---

FROM alpine:latest as package

COPY --from=build /opt/app/assets/ /opt/app/dist/

RUN apk add zip \
    && cd /opt/app/dist \
    && zip -r /tmp/package.zip .

