# Running a local instance of Plutus Playground in Docker

Provided you already have a working Docker installation, all you have to do is to run the following:
```bash
docker-compose build --build-arg PLUTUS_GIT_COMMIT=530cc134364ae186f39fb2b54239fb7c5e2986e9
docker-compose up -d
```

The build argument is optional and defaults to the latest commit.

Note that it requires quite a bit of patience until all sources have been downloaded and built.

To query the current version of Plutus Playground run
```bash
docker exec plutus-playground-docker_server_1 git rev-parse HEAD
```

The Playground can be stopped via:
```bash
docker-compose down
```
