# bill-talks-ai-docker-image
Docker image for the BillTalksAI.com website

# About
* This package uses Jekyll for the website and makes bootrap available via nodejs and npm (see how to use)
* This package includes Python for scripting and Pillow for image manipulation

# How to use
1. Create a new Dockerfile and add this line:
```
FROM billraymond/bill-talks-ai-docker-image:latest
```
2. If you want to use bootstrap, copy `node_modules/bootstrap/dist` to your Jekyll assets directory and reference the files in layout
