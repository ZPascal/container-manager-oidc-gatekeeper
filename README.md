# Container Manager OIDC Gatekeeper

OIDC proxy container to establish a connection to an application via an OIDC Proxy based on the [gatekeeper](https://github.com/gogatekeeper/gatekeeper) proxy and the container process overlay [container-manager](https://github.com/ZPascal/container-manager)

The following container was created by a replacement of the [louketo-proxy](https://github.com/louketo/louketo-proxy) with the purpose to establish a connection to an internal K8s app via OIDC over the external network.

## Basic information about the application and the container
The Container Manager OIDC Gatekeeper is based on the [gatekeeper](https://github.com/gogatekeeper/gatekeeper) application and the [container-manager](https://github.com/ZPascal/container-manager) process overlay to start and control the application and an Alpine base image as base ground of the container.

## Installation, startup and configuration
### Installation and startup
#### Docker
```
docker pull z9pascal/container-manager-oidc-gatekeeper:1.7.0-latest
docker run -e OIDC_DISCOVERY_URL="" -e OIDC_CLIENT_ID="" -e OIDC_CLIENT_SECRET="" -e OIDC_LISTEN_URL="0.0.0.0:3000" -e OIDC_ENCRYPTION_KEY="" -e OIDC_REDIRECT_URL="" -e OIDC_UPSTREAM_URL="https://kubernetes-dashboard" -v /storage:/storage -p 3000:3000 z9pascal/container-manager-oidc-gatekeeper:1.7.0-latest
```

#### Dev setup
After you modified the corresponding container with your changes, you can start the build and run process with the [docker-compose.yml](docker-compose.yml) file e.g. `docker-compose up -d` or you can use the following commands to start the build and run process for the development support manual.
```
docker build . -t container-manager-oidc-gatekeeper
docker run -e OIDC_DISCOVERY_URL="" -e OIDC_CLIENT_ID="" -e OIDC_CLIENT_SECRET="" -e OIDC_LISTEN_URL="0.0.0.0:3000" -e OIDC_ENCRYPTION_KEY="" -e OIDC_REDIRECT_URL="" -e OIDC_UPSTREAM_URL="https://kubernetes-dashboard" -v /storage:/storage -p 3000:3000 container-manager-oidc-gatekeeper
```

### Configuration
You set up all related configuration parameters like the OIDC proxy credentials and the configuration parameters via environment variables. You can check out the corresponding values and description of the values inside the following table.

| Environment variable |                     Description                      |        Example values        |
|:--------------------:|:----------------------------------------------------:|:----------------------------:|
|  OIDC_DISCOVERY_URL  | Describe the discovery url of the OIDC system/ realm |             xxx              |
|    OIDC_CLIENT_ID    |      Describe the client id of the OIDC client       |             xxx              |
|  OIDC_CLIENT_SECRET  |    Describe the client secret of the OIDC client     |             xxx              |
|   OIDC_LISTEN_URL    |      Describe the listen url of the OIDC proxy       |         0.0.0.0:3000         |
| OIDC_ENCRYPTION_KEY  |       Describe the OIDC session encryption key       |             xxx              |
|  OIDC_REDIRECT_URL   | Describe the redirect url of the OIDC system/ realm  |             xxx              |
|  OIDC_UPSTREAM_URL   |     Describe the upstream url of the OIDC proxy      | https://kubernetes-dashboard |

## Contribution

If you would like to contribute, have an improvement request, or want to make a change inside the code, please open a pull request and write unit tests.

## Support

If you need support, or you encounter a bug, please don't hesitate to open an issue.

## Donations

If you would like to support my work, I ask you to take an unusual action inside the open source community. Donate the money to a non-profit organization like Doctors Without Borders or the Children's Cancer Aid. I will continue to build tools because I like it and it is my passion to develop and share applications.

## License

This product is available under the Apache 2.0 [license](LICENSE).
