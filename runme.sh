#! /bin/bash

cd /content/stable-diffusion-webui/

if [[ -n "${LT}" ]]; then
  nohup lt -p 7860 > lt.log 2>&1 &
  sleep 3
  python /content/localtunnel_info.py
fi

# follow the wiki to install new models: https://sygil-dev.github.io/sygil-webui/docs/Installation/one-click-installer

wget -nc --header=$WGET_USER_HEADER https://huggingface.co/stabilityai/stable-diffusion-2/resolve/main/768-v-ema.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/768-v-ema.ckpt
wget -nc https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inference-v.yaml -O /content/stable-diffusion-webui/models/Stable-diffusion/768-v-ema.yaml

# Depth-guided model
wget -nc --header=$WGET_USER_HEADER https://huggingface.co/stabilityai/stable-diffusion-2-depth/resolve/main/512-depth-ema.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/512-depth-ema.ckpt
wget -nc https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-midas-inference.yaml -O /content/stable-diffusion-webui/models/Stable-diffusion/512-depth-ema.yaml

# Inpainting
wget -nc --header=$WGET_USER_HEADER https://huggingface.co/runwayml/stable-diffusion-inpainting/resolve/main/sd-v1-5-inpainting.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5-inpainting.ckpt

#VAE
wget -nc --header=$WGET_USER_HEADER https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5.vae.pt
wget -nc --header=$WGET_USER_HEADER https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt -O /content/stable-diffusion-webui/models/Stable-diffusion/sd-v1-5-inpainting.vae.pt
    
# Get GFPGAN
cd /content/stable-diffusion-webui/ && \
wget -nc https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth

# Download hypernetworks
cd /content/stable-diffusion-webui/models/ && \
wget -nc https://huggingface.co/Daswer123/gfdsa/resolve/main/hypernetworks.zip -O /content/stable-diffusion-webui/models/hypernetworks.zip && \
cd /content/stable-diffusion-webui/models && unzip -n hypernetworks.zip

# available params found here: https://github.com/sd-webui/stable-diffusion-webui/wiki/Command-line-options#list-of-command-line-options
# enable huge image generation
cd /content/stable-diffusion-webui && python3 launch.py --opt-split-attention --enable-insecure-extension-access --listen