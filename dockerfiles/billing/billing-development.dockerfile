FROM storjlabs/storjmodules
RUN ln -s /storj-base/node_modules/ /billing/node_modules
RUN npm install
WORKDIR /billing
CMD npm run start-dev
