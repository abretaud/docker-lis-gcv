# LIS Genomic Context Viewer Docker Image

This image contains a ready-to-go installation of [LIS](https://github.com/legumeinfo/) [Genomic Context Viewer](https://github.com/legumeinfo/lis_context_viewer).

## Usage

The docker image is automatically built on quay.io

[![Docker Repository on Quay](https://quay.io/repository/abretaud/lis-gcv/status "Docker Repository on Quay")](https://quay.io/repository/abretaud/lis-gcv)

```bash
docker pull quay.io/abretaud/lis-gcv
```

An example of [docker-compose.yml](./docker-compose.yml) file is available to help you setup a Chado database and a Tripal website.

## Configuration

This image exposes two ports:

- 8000 = a Django appplication exposing webservices
- 80 = a Nginx server serving static content

The [docker-compose.yml](./docker-compose.yml) file maps the port 8100 to the container port 80, which means you can access GCV by going to http://localhost:8100/

The following environment variables are available:

|Variable|Description|Default value|
|---|---|---|
|SITE_NAME|Site name (short, no spaces)|lis|
|SITE_FULL_NAME|Full site name|Legume Information System|
|GCV_URL|External URL to access GCV|http://localhost:8100|
|SERVICES_URL|External URL to access GCV API|http://localhost:8000/services|
|TRIPAL_URL|Address of a Tripal instance installed with tripal_phylotree module and a tripal_linkout module|https://legumeinfo.org|
|DEBUG|Set to 'true' to activate the debug mode|false|
|HOST|Hostname|gcv|

## Contributing

Please submit all issues and pull requests to the [abretaud/docker-tripal](http://github.com/abretaud/docker-lis-gcv) repository.

## Support

If you have any problem or suggestion please open an issue [here](https://github.com/abretaud/docker-lis-gcv/issues).
