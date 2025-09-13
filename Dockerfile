FROM ubuntu:24.04

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y neovim

# JavaScript/TypeScript dependencies
# RUN apt-get install -y nodejs
# RUN apt-get install -y npm
# RUN npm install -g typescript
# RUN npm install -g ts-node

CMD nvim
