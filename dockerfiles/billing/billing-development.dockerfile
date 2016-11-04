FROM storjlabs/storjmodules

RUN mkdir /billing
WORKDIR /billing

COPY ./billing/package.json /billing/package.json
RUN ln -s /storj-base/node_modules/ /billing/node_modules
RUN npm install

RUN npm i -g nodemon

CMD npm run start-dev
