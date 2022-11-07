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
    links2 \
    lsof \
    nano \
    net-tools \
    screen \
    sed \
    software-properties-common \
    unzip \
    w3m \
    wget \
    xdg-utils && \
  apt-get clean all

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh && chmod 777 Miniconda3-py39_4.12.0-Linux-x86_64.sh
RUN ./Miniconda3-py39_4.12.0-Linux-x86_64.sh -b
ENV PATH="/root/miniconda3/bin:${PATH}"
RUN conda install -c anaconda pip

# where to clone code and output results (will be mapped to a volume/folder of underlying OS)
RUN mkdir /content && mkdir /outputs
WORKDIR /content

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui && cd stable-diffusion-webui && \
  pip install -r requirements.txt

# Download hypernetworks
RUN cd /content/stable-diffusion-webui/models/ && \
  wget https://huggingface.co/Daswer123/gfdsa/resolve/main/hypernetworks.zip -O /content/stable-diffusion-webui/models/hypernetworks.zip && \
  cd /content/stable-diffusion-webui/models && unzip hypernetworks.zip 

# ENV user_header = "Authorization: Bearer <HF Token Here>"
RUN wget --header="Authorization: Bearer <HF Token Here>" https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5.ckpt
RUN wget --header="Authorization: Bearer <HF Token Here>" https://huggingface.co/runwayml/stable-diffusion-inpainting/resolve/main/sd-v1-5-inpainting.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5-inpainting.ckpt
#VAE
RUN wget --header="Authorization: Bearer <HF Token Here>" https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5.vae.pt
RUN wget --header="Authorization: Bearer <HF Token Here>" https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5-inpainting.vae.pt
    
# Get GFPGAN
RUN cd /content/stable-diffusion-webui/ && \
wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth

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
