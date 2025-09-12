FROM ghcr.io/prefix-dev/pixi:noble

ENV NB_USER=jovyan \
    NB_UID=1000 \
    SHELL=/bin/bash \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
ENV TZ=UTC

ENV HOME=/home/${NB_USER}
RUN echo "Creating ${NB_USER} user..." \
    # Change user name from ubuntu to jovyan
    && usermod --login ${NB_USER} ubuntu \
    # Change group name from ubuntu to jovyan
    && groupmod --new-name ${NB_USER} ubuntu \
    # Set home directory of jovyan user
    && usermod --home /home/${NB_USER} --move-home ${NB_USER} \
    # Make sure that /srv is owned by non-root user, so we can install things there
    && chown -R ${NB_USER}:${NB_USER} /srv

RUN apt update
RUN apt full-upgrade -y
RUN apt install -y git vim emacs nano silversearcher-ag tree

# Create the entrypoint
RUN echo 'pixi run "$@"' > /entrypoint.sh

# copy pixi.toml and pixi.lock to the container
COPY . ${HOME}
WORKDIR ${HOME}
USER ${NB_USER}

# install the default env
RUN pixi install
# Always run the shell hook
RUN mkdir -p ${HOME}/.bash.d \
    && pixi shell-hook > ${HOME}/.bash.d/init_pixi.sh \
    && echo ". ~/.bash.d/init_pixi.sh" >> ${HOME}/.bashrc

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
EXPOSE 8888
# CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--port=8888"]
