FROM ubuntu:latest

# install hugo
ENV HUGO_VERSION=0.31
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /usr/local/bin/

# install syntax highlighting
RUN apt-get update
RUN apt-get install -y python3-pygments

# build site
COPY . /source
RUN hugo -D --source=/source/ --destination=/public/

FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=0 /public/ /usr/share/nginx/html/
EXPOSE 80
