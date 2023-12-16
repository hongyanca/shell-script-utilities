# Use cloudflared to expose a Kubernetes app to the Internet

Based on https://developers.cloudflare.com/cloudflare-one/tutorials/many-cfd-one-tunnel/

This repository hosts a collection of utility scripts and templates tailored for exposing a Kubernetes app to the Internet using cloudflared tunnel.



## Usage

### cftun-token-to-json.sh

Use cftun-token-to-json.sh to convert cloudflared tunnel token to credentials.json file:

```shell
cftun-token-to-json.sh eyJhIjoiZBD1MGM4YjU3MG... > credentials.json
```



### Create a k8s secret

```shell
kubectl -n self-hosted create secret generic cf-tun-hello --from-file=credentials.json
```

The Secret name `cf-tun-hello` must be the same with the tunnel-name used in `gen-cf-tun-deploy.sh`



### cf-tun-template.yaml

https://github.com/cloudflare/argo-tunnel-examples/blob/master/named-tunnel-k8s/cloudflared.yaml

A template manifest file to connect your service to cloudflared tunnel.



### gen-cf-tun-deploy.sh

The `gen-cf-tun-deploy.sh` script must be executed in the same directory where the `cf-tun-template.yaml` file is located.

```shell
gen-cf-tun-deploy.sh <tunnel-name> <public-hostname> <protocol-service-port> <namespace>
```

This command generates a Deployment manifest file `deploy-tunnel-name.yaml` that establishes a connection from a Kubernetes HTTP service named `k8s-svc-in-same-ns`, which operates on port `5000` within the `production` Namespace, to a cloudflared tunnel that has the public hostname `hello.examples.com`:

```
gen-cf-tun-deploy.sh cf-tun-hello hello.examples.com http://k8s-svc-in-same-ns:5000 production
```

It creates a `deploy-cf-tun-hello.yaml` manifest file that can be used to create ConfigMap `cf-tun-hello` in Namespace `production` and a Deployment `cf-tun-hello` in Namespace `production`, which requires a Secret `cf-tun-hello` in the same Namespace.



### Deploy the cloudflared tunnel

Verify that a Secret with the same tunnel-name in the same Namespace is present.

```
kubectl -n production get secrets cf-tun-hello
```

Create the Deployment.

```
kubectl apply -f deploy-cf-tun-hello.yaml
```

Verify the Deployment.

```
kubectl -n production get deploy

NAME                READY   UP-TO-DATE   AVAILABLE   AGE
cf-tun-hello        2/2     2            2           2m
```



## Contributions

Contributions to this repository are welcome. Please ensure that you test any changes thoroughly before submitting a pull request.

## License

This project is licensed under the MIT License.