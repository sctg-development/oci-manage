# The very poor man high availability #

## Disclaimer ##

This is not a production ready solution.  
It is just a proof of concept.
It works for me. But I don't know if it will work for you. Remember that you are responsible for your own actions and backups are your friends.  

## Introduction ##

I have a Kubernetes v1.29.1 cluster running 8 nodes.  
2 nodes have the control-plane role.  
Cilium is the CNI, and Cilium replaces kube-proxy.  
On this 2 control-plane nodes I removed the NoSchedule taint for using them also as worker.  
ETCD replicates correctly beetween the 2 control planes. But it is not a high availability Kubernetes cluster.  
If the control-plane node fails, the cluster is not available anymore. Because on each node, the kubelet is configured to use the first control-plane node as API server.  
So, if the first control-plane node fails, the kubelet can't reach the API server anymore.  
I want to add a high availability layer to my cluster.

## My proposed solution ##

I cannot use a load balancer in front of the 2 control-plane nodes. Because I don't have any more nodes.  
So, I decided to use HAProxy on each node.  
First I edited the /etc/kubernetes/manifests/kube-apiserver.yaml file on each control-plane node for adding a `--bind-address` option because currently it listens on `:::6443`.  
Then I restarted the kubelet service on the two control-planes.  
I installed HAProxy on each node and I created the following configuration file:  

```ini
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend kubernetes-api
    bind 127.43.43.43:6443
    default_backend kubernetes-backend

backend kubernetes-backend
    balance roundrobin
    server master1 10.254.0.4:6443 check check-ssl verify none
    server master2 192.168.2.8:6443 check check-ssl verify none
```

It will listen on 127.43.43.43:6443 and redirect the traffic to the first control-plane node or the second one if the first is not available.  
On /etc/hosts I added the following line:  

```shell
127.43.43.43 k8s-api k8s-api.private
```

So, I can use k8s-api as API server address.  
I validated my setup by running the following command on each node:  

```bash
curl -k https://k8s-api.private:6443
```

On each node a control-plane answers to the curl request.  
I enabled the HAProxy service on each node and force it to start before the kubelet service. The idea is to add `Before=kubelet.service` in the `[Install]` section. I used the following command but it probably needs to be adapted to your distribution:  

```bash
sudo sed -i 's/After=network-online.target\(.*\)$/After=network-online.target\1\nBefore=kubelet.service/' /etc/systemd/system/multi-user.target.wants/haproxy.service
sudo systemctl daemon-reload
sudo systemctl enable --now haproxy

```

## Using kubeadm for regenerating the kube-api certificate ##

I want to add my poor man high availability cluster to the kube-apiserver certificate SANs.  
So I recovered the kubeadm configuration file:  

```bash
kubectl -n kube-system get cm kubeadm-config -o jsonpath='{.data.ClusterConfiguration}' > kubeadm-config.yaml
```

Now I added to the kubeadm configuration file the following lines:  

```yaml
apiServer:
  certSANs:
  - master1.private
  - master1
  - master2.private
  - master2
  - k8s-api
  - k8s-api.private
  - 10.254.0.4   # IP of the first control-plane node
  - 192.168.2.8  # IP of the second control-plane node
  - 127.43.43.43 # IP of the HAProxy
```

And I ran the following command:  

```bash
sudo kubeadm init phase certs apiserver --config kubeadm-config.yaml --dry-run 
```

Everything seems to be ok. So I renamed the current certificate and key files on each control-plane node:  

```bash
sudo mv /etc/kubernetes/pki/apiserver.crt /etc/kubernetes/pki/apiserver.crt.old
sudo mv /etc/kubernetes/pki/apiserver.key /etc/kubernetes/pki/apiserver.key.old
```

Now I issue a new certificate and key on each control-plane node:  

```bash
sudo kubeadm init phase certs apiserver --config kubeadm-config.yaml
```

I restarted the kubelet service on each control-plane node. With the command:

```bash
sudo systemctl restart kubelet
```

I edited the kubeadm-config ConfigMap using the following command:  

```bash
kubectl -n kube-system edit cm kubeadm-config
```

I added the previous certSANs to the kubeadm configuration ConfigMap.

## Edit the kubelet configuration ##

### On the worker nodes ###

I edited the /etc/kubernetes/kubelet.conf file on each node for editing the following lines:  

```yaml
    server: https://k8s-api.private:6443
```

finally I restarted the kubelet service on each worker node using the following command:  

```bash
sudo systemctl restart kubelet
```

### On the control-plane nodes ###

I edited the /etc/kubernetes/kubelet.conf, /etc/kubernetes/admin.conf, /etc/kubernetes/controller-manager.conf, /etc/kubernetes/scheduler.conf and /etc/kubernetes/super-admin.conf files on each node for editing the following lines:  

```yaml
    server: https://k8s-api.private:6443
```

finally I restarted the kubelet service on each control-plane node using the following command:  

```bash
sudo systemctl restart kubelet
```  

## Test the cluster ##

I ran the following command on each node:  

```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide
```

Everything seems to be ok.

## Future work ##

Any improvement is welcome.
