DEEP-OC-semseg_vaihingen
============================================

![DEEP-Hybrid-DataCloud logo](https://docs.deep-hybrid-datacloud.eu/en/latest/_static/logo.png)


[![Build Status](https://jenkins.indigo-datacloud.eu/buildStatus/icon?job=Pipeline-as-code%2FDEEP-OC-org%2FDEEP-OC-semseg_vaihingen%2Fmaster)](https://jenkins.indigo-datacloud.eu/job/Pipeline-as-code/job/DEEP-OC-org/job/DEEP-OC-semseg_vaihingen/job/master/)


This is a container that will simply run the DEEP as a Service API component,
with semseg_vaihingen (src: [semseg_vaihingen](https://github.com/deephdc/semseg_vaihingen)).

    
# Running the container

## Directly from Docker Hub

To run the Docker container directly from Docker Hub and start using the API
simply run the following command:

```bash
$ docker run -ti -p 5000:5000 deephdc/deep-oc-semseg_vaihingen:test
```

This command will pull the Docker container from the Docker Hub
[deephdc](https://hub.docker.com/u/deephdc/) repository and start the default command (deepaas-run --listen-ip=0.0.0.0).


## Running via docker-compose

docker-compose.yml allows you to run the application with various configurations via docker-compose.

**N.B!** docker-compose.yml is of version '2.3', one needs docker 17.06.0+ and docker-compose ver.1.16.0+, see https://docs.docker.com/compose/install/

If you want to use Nvidia GPU, you need nvidia-docker and docker-compose ver1.19.0+ , see [nvidia/FAQ](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#do-you-support-docker-compose)

**N.B.** For either CPU-based or GPU-based images you can also use [udocker](https://github.com/indigo-dc/udocker).


## Building the container

If you want to build the container directly in your machine (because you want
to modify the `Dockerfile` for instance) follow the following instructions:

Building the container:

1. Get the `DEEP-OC-semseg_vaihingen` repository:

    ```bash
    $ git clone -b test https://git.scc.kit.edu/deep/DEEP-OC-semseg_vaihingen
    ```

2. Build the container:

    ```bash
    $ cd DEEP-OC-semseg_vaihingen
    $ docker build -t deephdc/deep-oc-semseg_vaihingen .
    ```

3. Run the container:

    ```bash
    $ docker run -ti -p 5000:5000 deephdc/deep-oc-semseg_vaihingen
    ```

These three steps will download the repository from GitHub and will build the
Docker container locally on your machine. You can inspect and modify the
`Dockerfile` in order to check what is going on. For instance, you can pass the
`--debug=True` flag to the `deepaas-run` command, in order to enable the debug
mode.

# Connect to the API

Once the container is up and running, browse to `http://localhost:5000` to get
the [OpenAPI (Swagger)](https://www.openapis.org/) documentation page.
