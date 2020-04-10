FROM cimg/base:2020.01

RUN mkdir -p ~/bin ~/nvim && \
    cd ~/nvim && \
    curl -L https://github.com/neovim/neovim/releases/download/v0.4.3/nvim.appimage -o nvim.appimage && \
    chmod +x ./nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    ln -s ~/nvim/squashfs-root/usr/bin/nvim ~/bin/nvim
