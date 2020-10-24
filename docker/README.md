

## Preflight

You will need [Docker installed](https://www.docker.com/community-edition) on your workstation; make sure it is a recent version.

Check out a copy of the project with:

    git clone https://github.com/peteclarkez/embedPyPi.git

## Building

To build locally the project you run:

    docker build -t embedpypi -f docker/Dockerfile .

Once built, you should have a local `embedpypi` image, you can run the following to use it:

    docker run -it embedpypi