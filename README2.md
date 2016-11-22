In-container
============

- build individual images
  (may require submodule dockerfiles)
- build submodule and dep images
  (requires submodule dockerfiles)


Host
============
- submodule init and update (given storj-base feature branch)
- run submodule composition service
  - mount submodule on /
  - mount local storj-base somewhere
    (ensure local storj-base submodules are npm linked)
- up submodule composition
  - mount submodule on /
  - mount local storj-base somewhere
    (ensure local storj-base submodules are npm linked)
- down submodule composition
- build submodule composition


submodule:build [--deps] <submodule name>
submodule:update <submodule name>
submodule:up <submodule name>
submodule:run <submodule name>


docker:build <name>


Workflow
========

Initial Setup:
--------------

1. Clone this repo:

    `git clone git@github.com:Storj/storj-base`
  
1. Fetch remote branches:

    `git fetch origin`
  
1. Checkout branch whose name matches the submodule/project you're working on:

    `git co <submodule / project name>`

     e.g. `git co billing`
  
1. Pull down `storjlabs/thor` and `storjlabs/node-storj` images from dockerhub
    1. `docker pull storjlabs/thor`
    2. `docker pull storjlabs/node-storj`
    
    


Switching submodules
--------------------

1. Checkout a submdoule / feature branch:

    `git checkout <branch name>` OR `git checkout -b <branch name>`
    
    _NOTE: need to switch branches to change the HEAD of the submodules_
    
1. Run `submodule:update` thor task to init and update your git submodules

    `./thor.sh submodule:update <submodule name>`
  
  
  
Working on a submodule
----------------------
  
Git submodules are used to track where in VCS history storj deps need to be for a given submodule, outside of npm. This allows for submodules to have depencendies on unpublished modules which is important for staging environments.
  
A submodule, once inited updated, acts like it's own git repo. If you cd into the root of a submodule, you will have all the same git commands as usual but instead of having a `.git` directory, there is a `.git` file that references a location in the parent repo's `.git` directory.

#### To up a submodule [composition]() or [service]():

`./thor.sh submodule:up <submodule name> [service name]`


#### To run a submodule [service]():

`./thor.sh submodule:run <submodule name> <service name> [command]`



To install a new npm dep:
-------------------------

1. Use npm to add new dep to package.json:

    `npm i --save <dep>` OR `npm i --save-dev <dep>`
    
1. Rebuild submodule docker image (so npm can install in the container)
    
    `./thor.sh docker:build <submodule>`
    
    _NOTE: this rebuild workflow is only for development; in production, the `npm i` step in the `storjlabs/node-storj` dockerfile will handle node modules installation more efficiently_



To add a new submodule / project:
---------------------------------

### WIP

- TODO: add thor command to generate updated `.git/index` and `.gitmodules` files



