# Setup of Plutus Playground

## Prerequisites
* A Docker installation. For Windows, the WSL 2 based engine is recommended.
* Patience. Building and fetching all the sources will take on the order of 30 minutes an can vary widely with the quality of your internet connection and the machine you are using.
* Disk space: images built here are around 12 GB. 

## Running Plutus Playground
### Build the Plutus Playground images
Building is required only once on your machine and has to be repeated only for the purpose of updating.
```
docker-compose build --build-arg PLUTUS_GIT_COMMIT=7b5829f2ac57fcfa25a5969ff602b48641b36ac3
```
The build argument `PLUTUS_GIT_COMMIT` refers to, in principle, any commit of [Plutus](https://github.com/input-output-hk/plutus). It is optional and defaults to the latest commit. (But beware of Docker caching!)
See further below for a list of tested commits.

### Plutus Pioneer Program
For the *Plutus Pioneer Program*, you should target a specific commit. Open the `cabal.project` file and look for `source-repository-package` with location [https://github.com/input-output-hk/plutus.git](https://github.com/input-output-hk/plutus.git).

The specified tag, e.g., `7b5829f2ac57fcfa25a5969ff602b48641b36ac3` for week06, should be used as `PLUTUS_GIT_COMMIT`. 

| Week | PLUTUS_GIT_COMMIT                                                                                                                     |
|:----:|--------------------------------------------------------------------------------------------------------------------------------------:|
| 1    | [`ea0ca4e9f9821a9dbfc5255fa0f42b6f2b3887c4`](https://github.com/input-output-hk/plutus/tree/ea0ca4e9f9821a9dbfc5255fa0f42b6f2b3887c4) |
| 2    | [`81ba78edb1d634a13371397d8c8b19829345ce0d`](https://github.com/input-output-hk/plutus/tree/81ba78edb1d634a13371397d8c8b19829345ce0d) |
| 3    | [`219992289c6615e197069d022735cb4059d43229`](https://github.com/input-output-hk/plutus/tree/219992289c6615e197069d022735cb4059d43229) |
| 4    | [`2fbb7abb22138a434bb6c4f663a81e9b9dc51e98`](https://github.com/input-output-hk/plutus/tree/2fbb7abb22138a434bb6c4f663a81e9b9dc51e98) |
| 6    | [`8a20664f00d8f396920385947903761a9a897fe0`](https://github.com/input-output-hk/plutus/tree/8a20664f00d8f396920385947903761a9a897fe0) |
| 7    | [`8a20664f00d8f396920385947903761a9a897fe0`](https://github.com/input-output-hk/plutus/tree/8a20664f00d8f396920385947903761a9a897fe0) |
| 8    | [`2f11c28bd8f6d630daab582255e16d8408075bd7`](https://github.com/input-output-hk/plutus/tree/2f11c28bd8f6d630daab582255e16d8408075bd7) |
| 9    | [`7b5829f2ac57fcfa25a5969ff602b48641b36ac3`](https://github.com/input-output-hk/plutus/tree/7b5829f2ac57fcfa25a5969ff602b48641b36ac3) |
| 10   | [`7b5829f2ac57fcfa25a5969ff602b48641b36ac3`](https://github.com/input-output-hk/plutus/tree/7b5829f2ac57fcfa25a5969ff602b48641b36ac3) |


For older releases that were used in the first cohort of the *Plutus Pioneer Program*, please checkout the branch *first-cohort*.

### Start the Plutus Playground containers
After completing the build step, you can start the most recently built version via:
```
docker-compose up -d
```

To visit *Plutus Playground*, navigate to [https://localhost:8009/](https://localhost:8009/) and accept the security risk. This may take several minutes to start.

### Use the Plutus-Core image to build projects from the Plutus Pioneer Program
You can also use the plutus-core image to build projects from the [Plutus Pioneer Program](https://github.com/input-output-hk/plutus-pioneer-program).
The first thing you have to do, is to build the image. If you have previously built the docker-compose file, this will be very fast thanks to Docker's caching feature.
```Powershell
cd build
docker build --target plutus-core --build-arg PLUTUS_GIT_COMMIT=7b5829f2ac57fcfa25a5969ff602b48641b36ac3 --tag plutus-core:cohort2-week2 .
```

Then, you can run the image inside your existing clone of the *Plutus Pioneer Program* project:
```Powershell
docker run --volume=${PWD}:/plutus-pionieer-program -it plutus-core:cohort2-week2 nix-shell
```
Of course, you can also omit the `--volume` and clone [Plutus Pioneer Program](https://github.com/input-output-hk/plutus-pioneer-program) inside the container.

If you encounter an error similar to the following, you probably ran into [this open issue of cabal](https://github.com/haskell/cabal/issues/6126).
```
dieVerbatim: user error (cabal: '/usr/bin/wget' exited with an error:
/usr/bin/wget: unrecognized option: input-file=-
BusyBox v1.33.1 () multi-call binary.
```
This error is coming from `wget` as provided via `apk`. An easy workaround is to install another version of `wget` by running `nix-env --install wget`, which automatically hides `apk`'s wget.

You will also need to invoke `cabal update` before running `cabal build` on one of the projects.

### Shutdown
The Playground can be stopped via:
```
docker-compose down
```


## Maintenance 
In case you forgot when you last ran `docker-compose build`, you can query the current version of Plutus Playground by
```
docker exec plutus-playground-docker_server_1 git rev-parse HEAD
```
The container name *plutus-playground-docker_server_1* (auto-generated by Docker compose) might require some adjustments.

## Running the documentation
This is analog to the [previously described](#build-the-plutus-playground-images) setup of the Playground except that you have to specify the alternate compose file.
### Build the images
```
docker-compose -f docker-compose-docs.yml build --build-arg PLUTUS_GIT_COMMIT=<commit>
```
### Start the container

```
docker-compose -f docker-compose-docs.yml up -d
```

* To visit the *Cardano documentation*, navigate to [http://localhost:8002/](http://localhost:8002/).
* To visit the *Plutus Haddock documentation*, navigate to [http://localhost:8081/](http://localhost:8081/).

## Troubleshooting
* Insufficient disk space with the *WSL 2* based Docker engine on Windows
  - Move the disk image from its default location `%LOCALAPPDATA%\Docker\wsl\data\ext4.vhdx` to another disk as described [here](https://stackoverflow.com/questions/62441307/how-can-i-change-the-location-of-docker-images-when-using-docker-desktop-on-wsl2).
  - The entry `memory` in your [wsl configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig) *may* also have to be increased because, as it seems, the default is 50% of your primary disk independent on which disk the image resides.


## Links
* [Cardano documentation on *Plutus Playground*](https://docs.cardano.org/projects/plutus/en/latest/plutus/tutorials/plutus-playground.html])
* [*Plutus Pioneer Program* source code](https://github.com/input-output-hk/plutus-pioneer-program)
* [*Plutus Pioneer Program* Gitbook](https://docs.plutus-community.com)
* [Alternative Docker setup of the *Plutus Playground*](https://github.com/maccam912/ppp), which may be faster if you have a fast internet connection but slow local machine.
