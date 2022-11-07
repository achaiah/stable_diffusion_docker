#! /bin/bash

cd /content/stable-diffusion-webui/

if [[ -n "${LT}" ]]; then
  nohup lt -p 7860 > lt.log 2>&1 &
  sleep 3
  python /content/localtunnel_info.py
fi
# available params found here: https://github.com/sd-webui/stable-diffusion-webui/wiki/Command-line-options#list-of-command-line-options
# enable huge image generation
python3 launch.py --opt-split-attention --enable-insecure-extension-access --listen