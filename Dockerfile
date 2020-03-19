FROM ubuntu:18.10

###############################################################################
#
#              Install Core Packages
#
###############################################################################

RUN \
   # unminimize https://wiki.ubuntu.com/Minimal
      yes y | unminimize && \
   # initial update and upgrade
      apt-get update -qq && apt-get upgrade -y && \
   # install core packages
      apt-get install -qq -y \
         ca-certificates \
         curl \
         # support for apt-key keyservers
         dirmngr \
         # support for apt-key gpg keys
         gpg-agent \
         # support for changing locales
         locales \
         lsof \
         man \
         man-db \
         mosh \
         openssh-server \
         # suppport for add-apt-repository
         software-properties-common \
         sudo \
         systemd \
         --no-install-recommends && \
   # cleanup
      rm -rf /var/lib/apt/lists/* && \
      # cleanup our apt caches
      rm -rf /var/cache/apt/archives


###############################################################################
#
#              Add our user
#
###############################################################################

ARG NewUserName="nomad"
ARG NewUserHome="/home/${NewUserName}"

RUN useradd -ms /bin/bash ${NewUserName} && \
   # add the new user to the sudo group
   usermod -aG sudo ${NewUserName} && \
   #usermod -aG docker ${NewUserName} && \
   # unlock the account and give it an impossible password
   usermod -p '*' ${NewUserName} && \
   # Make sure we can run sudo without a password
   echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


###############################################################################
#
#              Install Software
#
###############################################################################

ARG BatVersion="0.10.0"
ARG DockerComposeVersion="1.24.0"
ARG NodeVersion="node_10.x"
ARG ScalaMetalsVersion="0.5.0"

# TODO this doesn't work
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE="DontWarn"

RUN \
   # add additional Package Archives
      # docker package repository
      curl -sSfL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
         add-apt-repository \
         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
         $(lsb_release -cs) \
         stable" && \
      # neovim personal package repository
      add-apt-repository ppa:neovim-ppa/stable && \
      # mosh development version
      add-apt-repository ppa:keithw/mosh-dev && \
      # Node source package repository
      curl -sSfL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - && \
         DISTRO="$(lsb_release -s -c)" && \
         echo "deb https://deb.nodesource.com/${NodeVersion} $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
         echo "deb-src https://deb.nodesource.com/${NodeVersion} $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list && \
      # sbt package respository
      apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
         echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
      # yarn package repository
      curl -sSfL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
         echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
      # update after adding new package archives
      apt-get update -qq && \
   # install packages
      apt-get install -qq -y \
         # Security
         #libpam-google-authenticator \
         build-essential \
         containerd.io \
         docker-ce \
         docker-ce-cli \
         gdb \
         git \
         neovim \
         nodejs \
         openjdk-8-jdk \
         python3 \
         # needed for bloop install
         python-argparse \
         python3-dev \
         python3-pip \
         python3-setuptools \
         sbt \
         scala \
         # install this early because coc needs it
         yarn \
         --no-install-recommends && \
   # add Python 3 support for NeoVim
      #pip3 install pynvim && \
   # add NVR for NeoVim https://github.com/mhinz/neovim-remote
      pip3 install neovim-remote && \
   # install bat https://github.com/sharkdp/bat
      curl -sSfL https://github.com/sharkdp/bat/releases/download/v${BatVersion}/bat_${BatVersion}_amd64.deb \
         -o /tmp/bat.deb && \
      dpkg -i /tmp/bat.deb && \
   # install docker compose
      curl -sSfL https://github.com/docker/compose/releases/download/${DockerComposeVersion}/docker-compose-$(uname -s)-$(uname -m) \
         -o /usr/local/bin/docker-compose && \
         chmod 755 /usr/local/bin/docker-compose && \
   # install pwndbg https://github.com/pwndbg/pwndbg
      # git clone --single-branch -b setup https://github.com/dylanowen/pwndbg.git /usr/local/bin/pwndbg/ && \
      #    (cd /usr/local/bin/pwndbg && exec ./setup.sh) && \
   # install Scala Metals
      curl -sSfL https://git.io/coursier -o /tmp/coursier && \
      chmod +x /tmp/coursier && \
      /tmp/coursier bootstrap \
         --java-opt -XX:+UseG1GC \
         --java-opt -XX:+UseStringDeduplication  \
         --java-opt -Xss4m \
         --java-opt -Xms100m \
         --java-opt -Dmetals.client=coc.nvim \
         --java-opt -Dmetals.http=true \
         org.scalameta:metals_2.12:${ScalaMetalsVersion} \
         -r bintray:scalacenter/releases \
         -r sonatype:snapshots \
         -o /usr/local/bin/metals-vim -f && \
   # install zero-http https://github.com/dylanowen/zero-http
      curl -sSfL https://github.com/dylanowen/zero-http/raw/master/bin/linux-zero-http \
         -o /usr/local/bin/zero-http && \
         chmod 751 /usr/local/bin/zero-http && \
   # final cleanup
      rm -rf /var/lib/apt/lists/* && \
      # cleanup our apt caches
      rm -rf /var/cache/apt/archives && \
      # remove temp downloads (to reduce docker image size)
      rm -rf /tmp/*


# Setup our locale for mosh
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
   locale-gen --purge $LANG && \
   dpkg-reconfigure --frontend=noninteractive locales && \
   update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE


###############################################################################
#
#              Setup SSH
#
###############################################################################
COPY ssh/sshd_config /etc/ssh/
# Remove the existing key files to ensure we're using our own from sshd_config
RUN rm /etc/ssh/ssh_host_*_key*


###############################################################################
#
#              Switch to our user
#
###############################################################################

# Add additional user groups to our user
RUN usermod -aG docker ${NewUserName}

USER ${NewUserName}
WORKDIR ${NewUserHome}


###############################################################################
#
#              Install Rust
#
###############################################################################
RUN curl -sSfL https://sh.rustup.rs | \
   sh -s -- --default-toolchain stable -y && \
   . $HOME/.cargo/env && \
   # install Wasm Pack
   curl -sSfL https://rustwasm.github.io/wasm-pack/installer/init.sh | sh && \
   # install rust components
   rustup component add \
      rls \
      rustfmt \
      rust-analysis \
      rust-src


###############################################################################
#
#              Install Bloop
#
###############################################################################
RUN curl -L https://github.com/scalacenter/bloop/releases/download/v1.2.5/install.py | python
   #systemctl --user enable $HOME/.bloop/systemd/bloop.service && \
   #systemctl --user daemon-reload


###############################################################################
#
#              Install NeoVim Plugins and Configure
#
###############################################################################
RUN mkdir -p ~/.config/nvim && \
   curl -sSfLo ~/.config/nvim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ADD nvim ${NewUserHome}/.config/nvim/
RUN nvim --headless +PlugInstall +qa


# COPY authorized_keys /home/${NewUserName}/.ssh/
# RUN sudo chown -R ${NewUserName}:${NewUserName} .ssh && \
#    chmod 700 ~/.ssh && \
#    chmod 600 ~/.ssh/authorized_keys
#RUN mkdir ~/.ssh && curl -fsL https://github.com/username.keys > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys


###############################################################################
#
#              Setup Volumes
#
###############################################################################
RUN mkdir -p ${NewUserHome}/code && \
   mkdir -p ${NewUserHome}/.gradle
VOLUME \
   "${NewUserHome}/code" \
   "${NewUserHome}/.gradle" \
   # User SSH Config
   "${NewUserHome}/.ssh" \
   # HostKeys for the server
   "/etc/ssh/keys"


###############################################################################
#
#              Dot Files
#
###############################################################################
COPY .bash_profile .gitconfig ${NewUserHome}/
COPY zero-http ${NewUserHome}/.zero-http/


###############################################################################
#
#              Expose Ports
#
###############################################################################
EXPOSE \
   # ssh
   22 \
   # metals doctor
   5031 \
   # mosh udp
   60000-61000/udp


COPY bin/entrypoint.sh /usr/local/bin/nomad-dev-entrypoint.sh
COPY bin/shutdown.sh /usr/local/bin/ndev-shutdown
ENTRYPOINT ["/usr/local/bin/nomad-dev-entrypoint.sh"]
