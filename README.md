# subsync in Docker
Docker build for [sc0ty/subsync](https://github.com/sc0ty/subsync)

[Dockerhub/subsyncdkr](https://hub.docker.com/repository/docker/pannal/subsyncdkr)

`subsync` itself only provides a snap build as portable. 
As it requires a lot of dependencies to be installed, this does that using Docker.

This is strictly Linux for now.

Usage: `docker run -it subsyncdkr:latest`
Options: All of the subsync options. The only default set is `--cli`
