# Stable Diffusion docker file

This is a dockerized version of the project by [daswer123](https://github.com/daswer123/stable-diffusion-colab).

The project now relies on [AUTOMATIC1111's](https://github.com/AUTOMATIC1111/stable-diffusion-webui) repo. The features of the UI are described [here](https://github.com/AUTOMATIC1111/stable-diffusion-webui-feature-showcase).

This should go without saying but you need an NVIDIA graphics card with at least 8GB RAM. Rumor has it that you can run it even on 4GB but you will be very limited in your results.

## Build

Build as you would any normal docker image. Image name can be whatever you want it to be (I called it `achaiah.local` in this case) E.g.:

```bash
DOCKER_BUILDKIT=0 docker build -t achaiah.local/ai.inference.stable_diffusion_webui:latest -f Dockerfile .
```

## Run
With docker running, execute:

```bash
docker run \
--name local_diffusion \
-it \
-p 7860:7860 \
--rm \
--init \
--gpus all \
--ipc=host \
--ulimit memlock=-1 \
--ulimit stack=67108864 \
-v </your/local/output/path>:/content/stable-diffusion-webui/log \
achaiah.local/ai.inference.stable_diffusion_webui:latest
```

Note the `-v` argument. If you want your images to be preserved after docker shuts down you will want to map a local path to the output produced by `webui`.

For devs: there are many other flags available that you can add to `runme.sh`. For a full list see [this file](https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/modules/shared.py#L16).

### Sharing

Localtunnel is installed to provide public access to anyone you'd like. To enable it, start docker with `-e LT=Y` 
`LTENDPOINT`. If you're running the docker image with `-it` above, you will see the endpoint printed in console. If you're running with `-d` (detached), you can find the info by entering the running container: `docker exec -it local_diffusion /bin/bash` and executing `cat /content/stable-diffusion-webui/lt.log`.