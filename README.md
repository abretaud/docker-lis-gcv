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

- 80 = a Django appplication exposing webservices
- 8100 = a Nginx server serving static content

## Contributing

Please submit all issues and pull requests to the [abretaud/docker-tripal](http://github.com/abretaud/docker-lis-gcv) repository.

## Support

If you have any problem or suggestion please open an issue [here](https://github.com/abretaud/docker-lis-gcv/issues).
