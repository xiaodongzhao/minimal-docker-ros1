FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04 as glvnd_runtime
FROM osrf/ros:melodic-desktop-full

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnome-terminal \
    build-essential \
    cmake \
    apt-utils \
    python3-pip \
    python-pip \
    git \
    python-tk \
    python-dev \
    language-pack-en \
    gconf2 \
    sudo \
    tmux \
    locales && \
    rm -rf /var/lib/apt/lists/*

# configure environmet
RUN update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX

# add user
ENV USERNAME ros
ARG USER_ID=1000
ARG GROUP_ID=15214

RUN groupadd --gid $GROUP_ID $USERNAME && \
        useradd --gid $GROUP_ID -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        usermod  --uid $USER_ID $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME

# Startup scripts
ENV LANG="en_US.UTF-8"
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /etc/profile.d/ros.sh && \
    echo "export QT_X11_NO_MITSHM=1" >> /etc/profile.d/ros.sh && \
    echo "export LANG=\"en_US.UTF-8\"" >> /etc/profile.d/ros.sh

# Install ROS packages
COPY ./dependencies.txt ./requirements.txt ./requirements3.txt /tmp/
RUN apt-get update && \
    sed "s/\$ROS_DISTRO/$ROS_DISTRO/g" "/tmp/dependencies.txt" | xargs apt-get install -y && \
    pip install -r /tmp/requirements.txt && \
    pip3 install -r /tmp/requirements3.txt && \
    rm -rf /var/lib/apt/lists/*

# Support for Nvidia docker v2
RUN apt-get update && apt-get install -y --no-install-recommends \
        pkg-config \
        libxau-dev \
        libxdmcp-dev \
        libxcb1-dev \
        libxext-dev \
        libx11-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=glvnd_runtime \
  /usr/share/glvnd/egl_vendor.d/10_nvidia.json \
  /usr/share/glvnd/egl_vendor.d/10_nvidia.json
COPY --from=glvnd_runtime \
  /usr/lib/x86_64-linux-gnu \
  /usr/lib/x86_64-linux-gnu
RUN echo '/usr/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig
    
# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

USER ros

RUN rosdep update
# Configure terminal colors
RUN gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false && \
    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false && \
    gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#000000"

COPY ./docker_entrypoint.sh /tmp
USER root
ENTRYPOINT ["/tmp/docker_entrypoint.sh"]
