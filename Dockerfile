# Wiki for installation instructions: https://github.com/sd-webui/stable-diffusion-webui/wiki/Installation

FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

# Set timezone to yours
RUN ln -fs /usr/share/zoneinfo/US/Central /etc/localtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get -y install \
    ca-certificates \
    cmake \
    curl \
    git \
    graphviz \
    grep \
    krb5-user \
    less \
    libffi-dev \
    libgl1-mesa-dev \
    libjpeg-dev \
    libssl-dev \
    lsof \
    nano \
    net-tools \
    screen \
    sed \
    software-properties-common \
    unzip \
    wget && \
  apt-get clean all

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh && chmod 777 Miniconda3-py39_4.12.0-Linux-x86_64.sh
RUN ./Miniconda3-py39_4.12.0-Linux-x86_64.sh -b
ENV PATH="/root/miniconda3/bin:${PATH}"
RUN conda install -c anaconda pip

# where to clone code and output results (will be mapped to a volume/folder of underlying OS)
RUN mkdir /content && mkdir /outputs
WORKDIR /content
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui && cd stable-diffusion-webui && \
  pip install -r requirements.txt && \
  mkdir repositories && \
  git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
  git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
  git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && \
  git clone https://github.com/salesforce/BLIP.git repositories/BLIP && \
  pip install -r repositories/CodeFormer/requirements.txt

RUN cd /content/stable-diffusion-webui/ && \
  wget "https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl&mode=grid&download=1" -O /content/stable-diffusion-webui/model.ckpt && \
  wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth

RUN cd /content/stable-diffusion-webui && git pull

# Change maximum steps to 500
RUN wget https://pastebin.com/raw/JUQ0Heq6 -O /content/stable-diffusion-webui/ui-config.json

COPY fix_line.py /content
RUN python /content/fix_line.py

RUN pip uninstall -y pillow pillow-simd && CC="cc -mavx2" pip install -U --force-reinstall pillow-simd

# Install localtunnel to enable public sharing
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt install -y nodejs

RUN cd /content/stable-diffusion-webui && npm install -g localtunnel
COPY localtunnel_info.py /content

## Print some info about the install
RUN echo "Python VERSION" && echo "----------" && python --version

# any changes of flags go into runme.sh
COPY runme.sh /
CMD [ "/bin/bash", "/runme.sh" ]

# Build with: DOCKER_BUILDKIT=0 docker build -t achaiah.local/ai.inference.stable_diffusion_webui:latest -f Dockerfile .
#
# Run new: docker run --name local_diffusion -it -p 7860:7860 --rm --init --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -v </your/local/output/path>:/content/stable-diffusion-webui/log achaiah.local/ai.inference.stable_diffusion_webui:latest
#
# To enable access to WebUI from the internet (via localtunnel) add environment variable to docker command: -e LT=Y
# docker run --name local_diffusion -it -p 7860:7860 --rm --init --gpus all -e LT=Y --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -v </your/local/output/path>:/content/stable-diffusion-webui/log achaiah.local/ai.inference.stable_diffusion_webui:latest
#
# To enter a running container:
# docker exec -it local_diffusion /bin/bash
