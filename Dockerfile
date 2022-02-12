FROM ubuntu:21.10

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y software-properties-common

RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update
RUN apt-get install -y neovim

CMD nvim
