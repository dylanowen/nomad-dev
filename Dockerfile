FROM ubuntu:18.10

ARG NewUserName="nomad"
ARG NewUserHome="/home/${NewUserName}"


###############################################################################
#
#              Install Software
#
###############################################################################

ARG BatVersion="0.10.0"
ARG NodeVersion="node_10.x"
ARG ScalaMetalsVersion="0.4.4"

RUN \
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
         mosh \
         openssh-server \
         # suppport for add-apt-repository
         software-properties-common \
         sudo \
         systemd \
         --no-install-recommends && \
   # add additional Package Archives
      # neovim personal package repository
      add-apt-repository ppa:neovim-ppa/stable && \
      # Node source package repository
      curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - && \
         DISTRO="$(lsb_release -s -c)" && \
         echo "deb https://deb.nodesource.com/${NodeVersion} $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
         echo "deb-src https://deb.nodesource.com/${NodeVersion} $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list && \
      # sbt package respository
      apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
         echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
      # yarn package repository
      curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
         echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
      # update after adding new package archives
      apt-get update -qq && \
   # install packages
      apt-get install -qq -y \
         # Security
         #libpam-google-authenticator \
         build-essential \
         openjdk-8-jdk \
         docker.io \
         git \
         neovim \
         nodejs \
         # python3-pip \
         # python3 \
         # python3-setuptools \
         sbt \
         scala \
         # install this early because coc needs it
         yarn \
         --no-install-recommends && \
   # add Python 3 support for NeoVim
      # pip3 install pynvim && \
   # install bat https://github.com/sharkdp/bat
      curl -sSfL https://github.com/sharkdp/bat/releases/download/v${BatVersion}/bat_${BatVersion}_amd64.deb \
         -o /tmp/bat.deb && \
      dpkg -i /tmp/bat.deb && \
   # install Scala Metals
   curl -sSfL https://git.io/coursier -o /tmp/coursier && \
      chmod +x /tmp/coursier && \
      /tmp/coursier bootstrap \
         --java-opt -XX:+UseG1GC \
         --java-opt -XX:+UseStringDeduplication  \
         --java-opt -Xss4m \
         --java-opt -Xms100m \
         #--java-opt -Dmetals.client=vim-lsc \
         org.scalameta:metals_2.12:${ScalaMetalsVersion} \
         -r bintray:scalacenter/releases \
         -r sonatype:snapshots \
         -o /usr/local/bin/metals-vim -f && \
   # final cleanup
      rm -rf /var/lib/apt/lists/* && \
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
#              Add our user
#
###############################################################################
RUN useradd -ms /bin/bash ${NewUserName} && \
   # add the new user to the sudo group
   usermod -aG sudo ${NewUserName} && \
   # unlock the account and give it an impossible password
   usermod -p '*' ${NewUserName} && \
   # Make sure we can run sudo without a password
   echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${NewUserName}
WORKDIR ${NewUserHome}


###############################################################################
#
#              Install Rust
#
###############################################################################
RUN curl https://sh.rustup.rs -sSf | \
   sh -s -- --default-toolchain stable -y && \
   . $HOME/.cargo/env && \
   # install Wasm Pack
   curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh && \
   # install rust components
   rustup component add rustfmt


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


###############################################################################
#
#              Setup SSH
#
###############################################################################
COPY sshd_config /etc/ssh/
COPY authorized_keys /home/${NewUserName}/.ssh/
RUN sudo chown -R ${NewUserName}:${NewUserName} .ssh && \
   chmod 700 ~/.ssh && \
   chmod 600 ~/.ssh/authorized_keys
#RUN mkdir ~/.ssh && curl -fsL https://github.com/username.keys > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys


###############################################################################
#
#              Volumes
#
###############################################################################
RUN mkdir -p ${NewUserHome}/code && \
   mkdir -p ${NewUserHome}/.gradle
VOLUME ["${NewUserHome}/code", "${NewUserHome}/.gradle"]


###############################################################################
# 22           :  ssh
# 60000-61000  :  mosh udp
###############################################################################
EXPOSE 22 60000-61000/udp

COPY .bash_profile ${NewUserHome}/

COPY entrypoint.sh /bin/entrypoint.sh
CMD ["/bin/entrypoint.sh"]
