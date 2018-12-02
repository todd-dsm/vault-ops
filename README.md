# vault-ops

For Vault on Google Cloud there's [vault-on-gke]. If you want to do it the hardway there's [vault-on-google-kubernetes-engine]. 

For everything else, there's _this_ - the Banzai Cloud [Vault Operator], backed by the [etcd Operator]. 

For now, the [Helm Charts/Vault-Operator] repo will be the primary reference point for use and further instruction.

## Limitations

This deployment crashes Minikube but before it does, Vault `v0.11.0` is installed. It has every appearance of being capable of going to the latest version.


## The Steps

```
git@github.com:todd-dsm/vault-ops.git && cd vault-ops
git checkout banzai
```

Check the version in `scripts/minikube.sh` and change it to whatever meets your requirements. Then run it to bootstrap `minikube`.

Everthing else is driven by the `Makefile`.

Install the Helm Tiller and source in your variables as instructed:

```
$ make prep 
helm init --upgrade
$HELM_HOME has been configured at /Users/thomas/.helm.

Tiller (the Helm server-side component) has been upgraded to the current version.
Happy Helming!
echo "source scripts/build.env auth"
source scripts/build.env auth           <- Instructions
```

Subequent scripts need the variables in `scripts/build.env`. The `Makefile` will have them by the time it needs them. I called the _release_ `auth`; pass in whatever string you want.

```
$ source scripts/build.env auth
++ export myRelease=auth
++ myRelease=auth
++ export KUBE_NS=default
++ KUBE_NS=default
++ export VAULT_ADDR=https://localhost:8200
++ VAULT_ADDR=https://localhost:8200
++ export VAULT_SKIP_VERIFY=true
++ VAULT_SKIP_VERIFY=true
++ set +x
```

The tiller pod needs about 30 seconds to get going; check status before moving forward. Example:

```
kubectl -n kube-system get pod tiller-deploy-7f4974b9c8-jz6cb 
NAME                            READY   STATUS    RESTARTS   AGE
tiller-deploy-7f4974b9c8-jz6cb  1/1     Running   0          1m
```

Deploy Vault

`make vault`

This takes a few minutes. Confirm everything is `STATUS=Running` and wait until `vault` itself has been up for at least **2-3 _more_ minutes**; for example:

```
NAME                            READY   STATUS    RESTARTS   AGE
pod/auth-74759c657d-522s9    1/2     Running   2          3m
...
```

Unseal the Vault

The `make unseal` fails; we'll fix this in post. If you know how, please feel free. For now, call the script with 1 argument, the _release_ :

`scripts/open_vault.sh auth`

# Experimentation
At this point Vault is up and running in Kubernetes and you are proxied out to the environment; [learn] and experiment. 

---

Clean-up

When you've done, do a:

`make clean`

This will remove Vault from Kubernetes and kill the `proxy` session to the cluster. 

After that, `minikube stop && minikube delete` to destroy the local Kubernetes environment.

Experiment: make sure the token/unseal keys don't persist:

`cat /tmp/jelly.out`


:fist:


[vault-on-gke]:https://github.com/sethvargo/vault-on-gke
[vault-on-google-kubernetes-engine]:https://github.com/kelseyhightower/vault-on-google-kubernetes-engine
[Vault Operator]:https://github.com/banzaicloud/bank-vaults
[etcd Operator]:https://coreos.com/blog/introducing-the-etcd-operator.html
[Helm Charts/Vault-Operator]:https://github.com/banzaicloud/bank-vaults#helm-chart
[some time]:https://github.com/coreos/vault-operator/issues/332#issue-335529485
[learn]:https://learn.hashicorp.com/vault/getting-started/first-secret