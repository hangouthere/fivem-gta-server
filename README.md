# FiveM Orchestrated Server

This is a quick setup of a server with all necessary `git` repositories linked in order to develop and deploy a FiveM GTA server!

The base image is based on [`spritsail/fivem`](https://github.com/spritsail/fivem), but then copied to the official Alpine Node16 image for development purposes.

## Setup

1 - Clone the repo locally:

```sh
git clone git@github.com:nerdfoundry/fivem-gta-server.git
cd fivem-gta-server
```

2 - Initialize and Update `git submodules`:

```sh
git submodules init
git submodule update
```

You now have an entire server config with associative repositories on disk!
Except it won't start fully yet, because the *default* Resources are missing from this repo!

3 - Using `docker compose` we can bring up the server, which will fail to fully start, but will allow us to do some more minor setup:

```sh
docker compose up
```

Since it will fail, you should see:

```
fivem  | [ citizen-server-impl] Couldn't find resource mapmanager.
fivem  | [ citizen-server-impl] Couldn't find resource chat.
fivem  | [ citizen-server-impl] Couldn't find resource spawnmanager.
fivem  | [ citizen-server-impl] Couldn't find resource sessionmanager.
fivem  | [ citizen-server-impl] Couldn't find resource fivem.
fivem  | [ citizen-server-impl] Couldn't find resource hardcap.
fivem  | [ citizen-server-impl] Couldn't find resource rconlog.
```

4 - Now in another terminal, let's `exec` into the container and copy those default resources over:

```sh
docker exec -it ash                     # Execute the `ash` shell on the fivem docker container
cp -r /opt/cfx-server-data/* /config    # Copy the cached default Resources from the docker container
exit                                    # Exit the docker container
```

5 - Quick fix for permissions, since operations were run as root, and you will want to edit files on your host (ie, outside of the container):

```sh
sudo chown -R $UID.$UID .
```

6 - Supply the following files:

* `license.cfg`
* `details.cfg`
* `rcon.cfg`
* `proxy.cfg` (if applicable)

and restart the container to start the server!

> You can find `*-example.cfg` files to copy from and supply necessary values

```sh
echo "set sv_licenseKey LICENSE_HERE" > ./config/license.cfg
# Edit other files as necessary...

docker compose down

# In the original terminal that was previously running the server
docker compose up
```

## Developing and Building Mods

When working on a mod, you'll want to have a quick build turnaround and ready to test.
The `docker` environment includes everything needed to work in both dev and build cycles.

```sh
git exec -it fivem ash          # Execute the `ash` shell on the fivem docker container
cd ./resources/\[sandbox\]/test # Navigate to the submodule/mod project you want to work on
npm i                           # Install npm dependencies
```

> On top of Building the Mod bundle, there are new npm packages that need to be added all the time. To ensure stability with the deployed version of node/npm that comes with FiveM, we need to do `npm` operations *inside* the FiveM server container.

Now you're ready to develop with a watch-server, or output a build bundle to test on other servers:

```sh
npm run watch       # Start development watch-server - changes are detected and built immediately
# or
npm run build       # Generate a production bundle for quick distribution
```

## New Mods

Once you've created a new mod `git` repository, you can add it to this repository to be included in the server orchestration:

```sh
# On the host system
git submodule add git@github.com:nerdfoundry/fivem-gta-mod-new-mod-category.git ./config/resources/\[new_mod_category\]
```
