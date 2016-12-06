FROM node:6
WORKDIR /root
RUN npm install -g yarn
CMD /bin/bash
