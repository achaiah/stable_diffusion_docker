print("!!!! ATTENTION !!!!")
print("!! LOCALTUNNEL IS ACTIVATED. YOUR INSTANCE IS EXPOSED TO THE INTERNET AT: ")
import os
with open('/content/stable-diffusion-webui/lt.log', 'r') as testwritefile:
    endpoint = str(testwritefile.read())
    print(endpoint)
    os.environ["LTENDPOINT"] = endpoint