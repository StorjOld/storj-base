Storj-base
==========

### [Glossary]()

This repo provides the following:

+ [Devops CLI tooling](#devops-cli-tooling)
      + [Build images/compositions](#usage)
      + [Development enviroment setup](#usage)
      + [Test automation / CI](#usage)
+ [Docker images](#docker-images)
      + [storjlabs/storj:base](#storjlabsstorjbase)
      + [storjlabs/storj:thor](#storjlabsstorjthor)
  
TODO:

+ File/dir naming conventions
+ 
+ Devops CLI generators/templates
      + Makefiles
      + [Docker composition files](#composition)
      + Dockerfiles



Devops CLI tooling
------------------
Ideally, all storj repos use the same tooling to provide a consistent devops interface across projects.

#### Goals

1. Flexible and extensible
2. Minimal dependencies

#### Constraints

1. Compatible with docker
1. Compatible with kubenetes

#### Dependencies

+ `bash` (or bash compatible shell)
+ `docker`
+ `docker-compose`

#### Methodology

Storj-base uses a couple of lightweight bash wrappers around docker for the main point-of-entry. `bash` is a pretty ubiquitous tool and should be most widely available.

These wrappers are used to invoke docker containers/compositions which provide  more powerful tools that would otherwise burden the host with additional dependencies. Using docker in this way also ensures a consistent environment when using the tools.

Control-flow:

1. User executes `./thor.sh <some thor command>` _(see [thor](#) in the glossary)_
2. [Thor](#thor-docshttpsgithubcomerikhudathorwiki) runs in a docker [composition](#composition), executing the corresponding task

[Thor](#thor-docshttpsgithubcomerikhudathorwiki) is used to perform most tasks as it's much better suited for defining and performing devops tasks than any javascript task runner I've used (e.g. grunt, gulp, etc.).


Additionally, when working in the storj-base repo, a [docker composition](#composition) ([thor.yml](./dockerfiles/thor.yml)) is used to provide access to the thor container as well as mounting the repo directory as a [volume](#volume) at `/storj-base`.

### Usage
To see what commands are availble run `make [command [sub-command [...]]] help`.

#### Building Images
To build [the images that this repo provides](#docker-images) run:

```bash
make build
```

By default this will only build the [storjlabs/storj:thor](#storjlabsstorjthor) image. If you want to also build [storjlabs/storj:base](#storjlabsstorjbase) you have to untag/remove it and then build:

```bash
docker rmi storjlabs/storj:base
make build
```

#### Development environment Setup

From the storj-base project root:

```bash
make setup <repo name> <your github username>
```

This will use the git submodules associated with this repo and `init` and `update` them (i.e. clone and checkout).

_(If the repo you're working on isn't available as a [git submodule](#submodule-see-git-submodule-docshttpsgit-scmcomdocsgit-submodule), you can [add it]())_

After your repo is `init`ed and `update`ed, a dependency tree is crawled starting from the repo's package.json's `devopsBase.npmLinkDeps` object.
This tree is used to run a series of `npm link` and `npm link <module name>` commands to ensure that all storj dependencies are linked locally and that there is only 1 instant of any of these modules.


Docker Images
-------------

### `storjlabs/interpreter`

Serves as a base image for all storj containers; it includes ruby 2 and node 6 interpreters.

Based on Debian jessie.

### `storjlabs/thor`

Provides the thorfiles, allowing the use of our devops tooling within images that build [`FROM`](https://docs.docker.com/engine/reference/builder/#/from) it.

Also provides `nettools`, `curl`, and `vim-tiny` utilities.


Tool Docs / Glossary
---------------------

### Make [(docs)](https://www.gnu.org/software/make/manual/make.html):

#### `goal`:
What `make` refers to as goals are analogous to `targets` or `tasks` in other task runner tools (e.g. grunt or thor).

#### `recipe`:
The bash code to execute for a given goal; the "body" if you will.


### Docker [(docs)](https://docs.docker.com/):

#### `image`:
The output of a `docker build ...` or `docker-compose build ...`; can be listed with `docker images`.
These images are used to create [containers](#container)

#### `container`:
An ephemeral virtual machine (linux container)

#### `composition`:
Refers to a `.yml` file used by docker-compose or the collective services' [containers](#container) which make it up.

#### `service`:
Refers to a single container or container configuration in a docker-compose [composition](#composition). See [docker's docs](https://docs.docker.com/compose/compose-file/#/service-configuration-reference)

#### `volume`: [see docker-compose docs](https://docs.docker.com/compose/compose-file/#/volumes-volumedriver)


### Git [(docs)](https://git-scm.com/documentation)

#### `submodule`: [see git submodule docs](https://git-scm.com/docs/git-submodule)


### Thor [(docs)](https://github.com/erikhuda/thor/wiki)


Guides
------

### Adding A Repo Submodule

You can add a git submodule to this repo so that it will be available when running `make setup ...` like so:

```bash
git submodule add <https github repo url>
```
_(NOTE: you must use the https url instead of the ssh url because the git commands are being executed in a docker container that doesn't have access to your ssh keys. Git remotes urls will be automatically rewritten to the ssh version when using `make setup`)_

Once you've `add`ed the submodule, you'll notice a file in your `git diff` corresponding to the submodule's directory on the filesystem e.g. for the `bridge-gui` submodule:
```bash
diff --git i/bridge-gui w/bridge-gui
index 45fbe3e..8ac466b 160000
--- i/bridge-gui
+++ w/bridge-gui
@@ -1 +1 @@
+Subproject commit 8ac466b79304abe7e24545fee72c6b651d03cf84
```

This file tells git where in version control history should be checked out when doing a `git submodule update` for that submodule and as such should be kept up to date in this repo (i.e. your fork / feature branch of storj-base)

Finally, you should ensure that you're new submodule's repo's package.json conatains a `devopsBase` object with an `npmLinkDeps` property whose value is an object that maps the npm module name to the git submodule name, optionally including a git refspec indicating where in version control history to check out. If a refspec is not provided, `make setup` defaults to highest compatible npm-published version tag.

_TODO: add documentation for `devopsBase` and `npmLinkDeps`_
_TODO: rename `devopsBase` to `storjBase` or something_
