[![en-US](https://img.shields.io/badge/lang-en--us-red.svg)](https://github.com/eltorio/oci-manage/blob/main/README.md)
[![fr-FR](https://img.shields.io/badge/lang-fr--fr-green.svg)](https://github.com/eltorio/oci-manage/blob/main/README.fr-FR.md)\
**This file is written in French, the other languages are automatically translated**

# 1. Oracle OCI-Kubernetes Lab *Bare Metal*

**This project is not intended to be reused, it is a kind of well-structured note**\
**If it's useful to you, so much the better!**\
**If you have corrections, additions, ideas they are welcome**

- [1. Oracle OCI-Kubernetes Lab *Bare Metal*](#1-oracle-oci-kubernetes-lab-bare-metal)
  - [1.1. Objectives](#11-objectives)
  - [1.2. Prerequisites](#12-prerequisites)
  - [1.3. Architecture](#13-architecture)
    - [1.3.1. Rental structure](#131-rental-structure)
    - [1.3.2. Choice](#132-choice)
    - [1.3.3. Creating Instances *Nodes*](#133-creating-instances-nodes)
    - [1.3.4. Network](#134-network)
      - [1.3.4.1. Multi-tenancy cases](#1341-multi-tenancy-cases)
        - [1.3.4.1.1. Creating Local Peering Gateways](#13411-creating-local-peering-gateways)
          - [1.3.4.1.1.1. Applicant](#134111-applicant)
          - [1.3.4.1.1.2. "Accepting"](#134112-accepting)
- [2. Installation of the control-plane](#2-installation-of-the-control-plane)
  - [2.1. 1 - Remote connection to the instance (with the super-private key) and creation of the operating user](#21-1---remote-connection-to-the-instance-with-the-super-private-key-and-creation-of-the-operating-user)
  - [2.2. 2 - Login as operator](#22-2---login-as-operator)
  - [2.3. 3 - Software Installation](#23-3---software-installation)
  - [2.4. Compiling CRI-Dockerd](#24-compiling-cri-dockerd)
  - [2.5. Installation of the Cilium Client](#25-installation-of-the-cilium-client)
  - [2.6. Manually creating the file `/etc/hosts` Control Plane](#26-manually-creating-the-file-etchosts-control-plane)
  - [2.7. Firewall definitions](#27-firewall-definitions)
- [3. Installing the active nodes (workers) from the control-plane](#3-installing-the-active-nodes-workers-from-the-control-plane)
- [4. HAProxy](#4-haproxy)
- [5. OCI-MANAGE](#5-oci-manage)
  - [5.1. Deploy the Hosts file](#51-deploy-the-hosts-file)
  - [5.2. Deploy the root certificate](#52-deploy-the-root-certificate)
  - [5.3. Deploy HAProxy Configuration (Deprecated)](#53-deploy-haproxy-configuration-deprecated)
  - [5.4. Updating Packages:](#54-updating-packages)
  - [5.5. Restart the cluster](#55-restart-the-cluster)
  - [5.6. Deploy a file](#56-deploy-a-file)
  - [5.7. Deploy the firewall](#57-deploy-the-firewall)
  - [5.8. (Re)create local interface files *e.g. in case of a change in routing*](#58-recreate-local-interface-files-eg-in-case-of-a-change-in-routing)
- [6. Cluster Deployment](#6-cluster-deployment)
  - [6.1. Certificate Authority](#61-certificate-authority)
    - [6.1.1. Deploying the CA](#611-deploying-the-ca)
  - [6.2. Control-Plane](#62-control-plane)
  - [6.3. Name Resolution](#63-name-resolution)
  - [6.4. Workers](#64-workers)
  - [6.5. Clearing the cluster and reinstalling the cluster](#65-clearing-the-cluster-and-reinstalling-the-cluster)
    - [6.5.1. Erasure](#651-erasure)
    - [6.5.2. Resettlement](#652-resettlement)
  - [6.6. Persistent storage](#66-persistent-storage)
    - [6.6.1. Longhorn](#661-longhorn)
    - [6.6.2. OpenEBS/jiva](#662-openebsjiva)
  - [6.7. Certificate Manager](#67-certificate-manager)
  - [6.8. Openness to the outside world](#68-openness-to-the-outside-world)
  - [6.9. Access to dashboards](#69-access-to-dashboards)
  - [6.10. Grafana](#610-grafana)
    - [6.10.1. Local Prometheus and Grafana Instance](#6101-local-prometheus-and-grafana-instance)
    - [6.10.2. Free Hosted Instance](#6102-free-hosted-instance)
  - [6.11. Local Container Registry](#611-local-container-registry)
    - [6.11.1. Create a specific name resolution:](#6111-create-a-specific-name-resolution)
    - [6.11.2. To add an image:](#6112-to-add-an-image)
    - [6.11.3. To uninstall the local registry:](#6113-to-uninstall-the-local-registry)
    - [6.11.4. User Interface](#6114-user-interface)
  - [6.12. Letsencrypt](#612-letsencrypt)
    - [6.12.1. Oracle OCI DNS01](#6121-oracle-oci-dns01)
      - [6.12.1.1. Installation](#61211-installation)
      - [6.12.1.2. Usage](#61212-usage)
      - [6.12.1.3. Uninstalling](#61213-uninstalling)
    - [6.12.2. Azure DNS](#6122-azure-dns)
      - [6.12.2.1. Installing the Azure CLI](#61221-installing-the-azure-cli)
      - [6.12.2.2. Installation](#61222-installation)
      - [6.12.2.3. Usage](#61223-usage)
      - [6.12.2.4. Uninstalling](#61224-uninstalling)
    - [6.12.3. Cloudflare CNAME Automatic Deployment](#6123-cloudflare-cname-automatic-deployment)
      - [6.12.3.1. Installation](#61231-installation)
      - [6.12.3.2. Example of use](#61232-example-of-use)
      - [6.12.3.3. Uninstalling](#61233-uninstalling)
  - [6.13. Helm-Dashboard](#613-helm-dashboard)
  - [6.14. Wireguard](#614-wireguard)
    - [6.14.1. Initialization](#6141-initialization)
    - [6.14.2. Adding a Node](#6142-adding-a-node)
    - [6.14.3. View Nodes](#6143-view-nodes)
    - [6.14.4. Deploying Nodes](#6144-deploying-nodes)
  - [6.15. File `README.md` multilingual](#615-file-readmemd-multilingual)
  - [6.16. Bird on the control-plane](#616-bird-on-the-control-plane)

## 1.1. Objectives

Create a bare-metal mock-up of a Kubernetes cluster using Oracle Cloud Infrastructure "always free" VMs.\
Try to automate deployment tasks as much as possible without using specific tools.\
All of the `snippets` authoring and automation is gathered in the script `oci-manage`

## 1.2. Prerequisites

*   one free OCI oracle account per person in the same region
*   A "super private" SSH key
*   A root CA to generate all certificates
*   a lot of time!

## 1.3. Architecture

Each member has their own "tenancy", they have deployed one, two, three or four VMs in their tenancy.

### 1.3.1. Rental structure

*   using the same OCI region
*   A child compartment of the root compartment containing all objects
*   a virtual private network with a CIDR of type 10.n.0.0/16
*   Two subnets:
    *   Public: CIDR 10.n.0.0/24
    *   Private: CIDR 10.n.1.0/24
*   n-1 local peering gateways (LPGs) with the names of the other tenancies
*   a site-to-site VPN between the tenancy and the Cisco router in the lab with BGP

### 1.3.2. Choice

| Element | Choice |
| :--------- | :----------------- |
| Cluster | Kubernetes v1.29.1 |
| CNI | Cilium 1.14.5 |
| Routing | BGP |
| Connections | VXLAN |
| VPN | IKEv2 |
| IRC | cri-containerd or Mirantis cri-docker |
By default the CRI (container runtime interface) is set with Mirantis cri-docker, to use the internal containerd plugin set the DOCKER_RUNTIME variable to containerd

### 1.3.3. Creating Instances *Nodes*

Each node is either:

*   **VM.Standard.A1.Flex instance (arm64)**

<img width="1223" alt="arm64" src="https://user-images.githubusercontent.com/6966689/230726371-91a67bb4-8830-43df-b36e-7b97596246cb.png">

*   **VM.Standard.E2.1.Micro instance (amd64)** .

 <img width="1190" alt="amd64" src="https://user-images.githubusercontent.com/6966689/230726465-cbab9f60-0a1a-4ce9-ab37-300301f6af6a.png">

Each instance is deployed with the minimum Ubuntu 22.04 image. What for? Because it's the OS we know best.
At the time of deploying each virtual machine, we put an SSH key that we call the "super private" key.  We use it to initiate the deployment.

### 1.3.4. Network

*   Creating security rules
    *   Public network
        *   No change
    *   Private Network
        *   We allow everything (for the lab)
            *   0.0.0.0/0 => all protocols
            *   ::/0 => all protocols

#### 1.3.4.1. Multi-tenancy cases

If the nodes are in different tenancies, the private networks of each tenancy must be linked:

##### 1.3.4.1.1. Creating Local Peering Gateways

*   Create Policies
    *   They must be created at the root compartment
    *   Strategies of the Claimant and the "Acceptors":

###### 1.3.4.1.1.1. Applicant

```sql
Allow group Administrators to manage local-peering-from in compartment <requestor-compartment>
Endorse group Administrators to manage local-peering-to in any-tenancy
Endorse group Administrators to associate local-peering-gateways in compartment <requestor-compartment> with local-peering-gateways in any-tenancy
```

###### 1.3.4.1.1.2. "Accepting"

```sql
Define tenancy Requestor as <requestor_tenancy_OCID>
Define group Administrators as <RequestorGrp_OCID>
Admit group Administrators of tenancy Requestor to manage local-peering-to in compartment <acceptor-compartment>
Admit group Administrators of tenancy Requestor to associate local-peering-gateways in tenancy Requestor with local-peering-gateways in compartment <acceptor-compartment>
```

*   Local peering gateways

    *   in the OCI/VCN console of the accepting gateway copy the OCID of the "accepting" gateway.

    <img width="1845" alt="acceptor2" src="https://user-images.githubusercontent.com/6966689/230727586-09d0a2b4-f3d5-4f96-8b3a-dfd3f1a27988.png">

    *   In the requestor's OCI/VCN console, to the right of the corresponding gateway, you will find in the menu "Establish an Appearance Connection. It is necessary to stick the previous ocid on it... If there's a permission issue, it's probably due to ill-defined policies. See https://docs.oracle.com/fr-fr/iaas/Content/Network/Tasks/localVCNpeering.htm#Step3

<img width="1847" alt="requestror" src="https://user-images.githubusercontent.com/6966689/230727600-2de47379-553d-43bf-84f8-2629f176e81e.png">

# 2. Installation of the control-plane

## 2.1. 1 - Remote connection to the instance (with the super-private key) and creation of the operating user

```sh
ssh -i clef_super_privée ubuntu@instance_ip
USERNAME=adminuser
PASSWORD=sonmotdepasse
sudo useradd -m -s /bin/bash -p $PASSWORD $USERNAME
sudo usermod -aG sudo "$USERNAME"
sudo -u "$USERNAME" sh -c "cd &&\
                                mkdir -p .ssh &&\
                                chmod go-rwx .ssh &&\
                                ssh-keygen -q -t ecdsa -f ~/.ssh/id_ecdsa -N ''"
sudo cp /home/ubuntu/.ssh/authorized_keys /home/$USERNAME/.ssh/
sudo -u "$USERNAME" sh -c "cd chmod go-rwx .ssh"
exit
```

## 2.2. 2 - Login as operator

```sh
ssh -i clef_super_privée adminuser@instance_ip
# définition du nom d'hôte
sudo hostnamectl hostname master.private.$compartment.oraclevcn.com
# création d'une clef ssh pour root
sudo ssh-keygen -t ecdsa
#autorisation du login root via ssh
sudo sed -i.bak s/#PermitRootLogin/PermitRootLogin/ /etc/ssh/sshd_config
sudo systemctl restart ssh
#modification du service docker
sudo sed -i.bak '/^\[Service\].*/a MountFlags=shared' /lib/systemd/system/docker.service
```

## 2.3. 3 - Software Installation

```sh
# installation du repo officiel Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
# installation du repo officiel Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/google-k8s.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/google-k8s.gpg] http://apt.kubernetes.io/ kubernetes-xenial main"| sudo tee /etc/apt/sources.list.d/k8s.list
# mise à jour de l'image de base Ubuntu 22.04 LTS (pour une instation propre)
sudo apt-get update && sudo apt-get dist-upgrade && sudo reboot
```

```sh
# installation
sudo apt-get update && sudo apt-get install vim wireguard iputils-ping docker-ce docker-ce-cli containerd.io docker-compose-plugin git golang-go iputils-ping cron kubeadm haproxy kubelet kubectl kubernetes-cni jq
# ajout de l'exploitant comme administrateur docker
sudo usermod -aG docker $USER
sudo reboot
```

## 2.4. Compiling CRI-Dockerd

*Be careful, if the cluster is multi-architecture, you must have a version of the executable for each architecture*

```sh
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
go get && go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
sudo install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sudo cp -a packaging/systemd/* /etc/systemd/system
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
```

## 2.5. Installation of the Cilium Client

```sh
cluster_init_get_cilium_cli
```

To check that everything is working `cilium status`.\ <img width="1083" alt="cilium" src="https://user-images.githubusercontent.com/6966689/230726758-95a7b598-f8a9-4ec1-a597-0a2f069868a3.png">

## 2.6. Manually creating the file `/etc/hosts` Control Plane

The host file of the plane control allows static name resolution.

```hosts
10.0.1.23       node1       node1.private.tenancy1.oraclevcn.com
10.0.0.63                   node1.public.tenancy1.oraclevcn.com
10.0.0.75       master      master.private.tenancy1.oraclevcn.com
10.0.0.54                   oci-master.public.tenancy1.oraclevcn.com
10.1.0.201      node2       node2.private.tenancy2.oraclevcn.com
10.1.1.186                  node2.public.tenancy2.oraclevcn.com
```

## 2.7. Firewall definitions

in /etc/iptables/rules.v4 has been added under the permission of the SSH port (22):

```sh
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT -m comment --comment "WEB secure incoming"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 2379:2380 -j ACCEPT -m comment --comment "K8S etcd access"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 4240 -j ACCEPT -m comment --comment "Cilium health API"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 4244 -j ACCEPT -m comment --comment "Cilium Hubble port"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 6443 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 8472 -j ACCEPT -m comment --comment "Cilium VXLAN tunnel"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10250 -j ACCEPT -m comment --comment "K8S node"
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10257 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10259 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 51820 -j ACCEPT -m comment --comment "Wireguard UDP port"
```

# 3. Installing the active nodes (workers) from the control-plane

**This can only be done if private networks are interconnected**\
Take a look at the script `oci-manage`\
It contains all the automation functions, they are not documented because we lack courage!\
At the beginning of the file there are a number of variables...\
Copy them to a file `./oci-manage-config.sh` and edit them.\
To activate the functions, you simply have to do `. ./oci-manage`

```sh
EXPLOITANT=adminuser
PASS=unvraimotdepasse
NODE_PUBLIC_IP=1.2.3.4
NODE_PRIVATE_FQDN=oci-node.private.tenancy.oraclevcn.com
PRIVATE_HOST_NAME=oci-node
PRIVATE_MAC=02:00:00:00:00:0F
PRIVATE_IP=10.0.1.267
init_create_admin_user_with_key $NODE_PUBLIC_IP $EXPLOITANT $PASS
init_allow_keys_for_root $NODE_PUBLIC_IP $EXPLOITANT $PASS
init_deploy_admin_keys_to_admin_user $NODE_PUBLIC_IP $EXPLOITANT
#init_set_ramdisk $NODE_PUBLIC_IP
init_set_iptables $NODE_PUBLIC_IP
init_set_hostname $NODE_PUBLIC_IP $NODE_PRIVATE_FQDN
#attention ne fonctionne que si cri-dockerd existe dans le cluster pour la bonne architecture
#voir les variables ARM_SRC et X86_64_SRC de oci-manage-config.sh
init_install_software $NODE_PUBLIC_IP $EXPLOITANT
#attendre que la machine soit de retour
init_install_cri_containerd $NODE_PUBLIC_IP
# sur les VM avec une carte réseau privée et une publique
# après avoir noté l'adresse mac et l'adresse ip privée de l'instance
init_create_private_interface "$PRIVATE_HOST_NAME" "$NODE_PUBLIC_IP" "$PRIVATE_MAC" "$PRIVATE_IP"
```

# 4. HAProxy

In most Kubernetes clusters, load balancing and routing within the cluster is supported by the data center infrastructure.\
In the case of a bare-metal cluster, there is no immediate solution to access the cluster's internal IP addresses from the Internet.\
MetalLB, for example, does not allow you to balance inbound access between the public IP addresses of each of the nodes.\
Another solution is to tinker with the netfilter table so that it forwards tcp packets to internal addresses. It's still tinkering.\
HAProxy offers an elegant solution.\
In layer 7 mode, HAProxy acts as a reverse proxy, but you have to configure all Ingress manually.\
You can use TCP mode (layer 4), but you lose the source IP address information (unless you use the HAProxy protocol which must be supported by the client).\
The solution I find ideal is to drive HAProxy automatically by HAProxy-ingress-controller which communicates with the cluster and configures on each HAProxy on each node.

# 5. OCI-MANAGE

When all nodes are pre-installed\
With `oci-manage` This allows "global" tasks to be carried out\
It is a set of functions *Bash* that we use to manage the cluster.\
Some are simple *Snippets* others are a bit more advanced.\
Functions *Useful* are listed in `cluster_help`\
To see what's in a *snippet* just extract it with `type xxxxxx`\
Example with the creation of the control-plane

```sh
type cluster_init_create_control_plane
cluster_init_create_control_plane is a function
cluster_init_create_control_plane () 
{ 
    if [ -z "${FUNCNAME[1]}" ]; then
        echo "call cluster_init_create_control_plane";
        IPAM="ipam.mode=cluster-pool,ipam.operator.clusterPoolIPv4PodCIDRList=$CILIUM_CLUSTER_POOL_IPV4_KUBERNETES_POD_CIDR";
    else
        echo "call cluster_init_create_control_plane_pool_kubernetes";
        IPAM="ipam.mode=kubernetes";
    fi;
    sudo mkdir -p /etc/kubernetes/pki/etcd;
    sudo cp -av /home/$USER/pki/* /etc/kubernetes/pki/;
    sudo chown -R root:root /etc/kubernetes;
    sudo kubeadm init --skip-phases=addon/kube-proxy --ignore-preflight-errors=NumCPU --pod-network-cidr=$KUBERNETES_POD_CIDR --service-cidr=$KUBERNETES_SERVICE_CIDR --cri-socket=unix:///run/cri-dockerd.sock --control-plane-endpoint=$CONTROL_PLANE_INTERNAL_ADDRESS --node-name $HOSTNAME --apiserver-advertise-address=$(/sbin/ip -o -4 addr list enp1s0 | awk '{print $4}' | cut -d/ -f1);
    set_systemd_resolve_to_k8s;
    rm -rf $HOME/.kube;
    mkdir -p $HOME/.kube;
    sudo mkdir -p /root/.kube;
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config;
    sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config;
    sudo chown $(id -u):$(id -g) $HOME/.kube/config;
    cilium install --version $CILIUM_VERSION --helm-set kubeProxyReplacement=strict,k8sServiceHost=$CONTROL_PLANE_IP,k8sServicePort=$CONTROL_PLANE_PORT,$IPAM,tunnel=vxlan,bpf.masquerade=true,bgpControlPlane.enabled=true,bgp.announce.loadbalancerIP=true,bgp.announce.podCIDR=true,hubble.relay.enabled=true,hubble.ui.enabled=true;
    cluster_init_create_ip_pool
}
```

Note that a number of variables are used. They are defined in a `oci-manage-config.sh` and the default values are at the top of the file `oci-manage`\
The path to the file `oci-manage-config.sh` is hard-coded at the end of the default values of `oci-manage`

```sh
# pour activer l'ensemble des fonctions de oci-manage
. ~/oci-manage
```

Each time a node is added, the CLUSTER_MEMBERS variable in the configuration file must be updated.\
Each time the variable changes, you have to call again `. ~/oci-manage`

## 5.1. Deploy the Hosts file

*   Manually create the file `sudo vi /etc/hosts` of the control-plane and then deploy it.

```sh
cluster_deploy_hosts
```

## 5.2. Deploy the root certificate

the one in the variable ROOT_CA

```sh
cluster_deploy_ca_cert
```

## 5.3. Deploy HAProxy Configuration (Deprecated)

```sh
cluster_deploy_haproxy_config_on_members
```

## 5.4. Updating Packages:

```sh
cluster_apt_dist_upgrade
```

## 5.5. Restart the cluster

```sh
cluster_reboot
```

## 5.6. Deploy a file

```sh
#en tant que root
cluster_copy_file_as_root /etc/hosts /etc/hosts
#sinon
cluster_copy_file_as_current_user ~/oci-manage ~/oci-manage
cluster_copy_file_as_current_user ~/oci-manage-config.sh ~/oci-manage-config.sh
```

## 5.7. Deploy the firewall

```sh
cluster_copy_file_as_root /etc/iptables/rules.v4 /etc/iptables/rules.v4
cluster_run_on_all_members_as_root "iptables-restore -t /etc/iptables/rules.v4"
```

## 5.8. (Re)create local interface files *e.g. in case of a change in routing*

```sh
cluster_recreate_private_interface
cluster_recreate_master_private_interface
```

# 6. Cluster Deployment

Normally all the machines are ready, we can check that they can communicate with each other:

```sh
cluster_ping_host_from_members $CONTROL_PLANE_LOCAL
```

Is it all good? We can get down to business.

## 6.1. Certificate Authority

To create a root certificate authority (CA) and a local authority (Sub CA) there are plenty of tutorials on the Internet. Wholesale:

```sh
mkdir ~/certs
cd ~/certs
# CA
openssl genrsa -out myCA.key 4096
openssl req -x509 -new -sha256 -extensions v3_ca -nodes -key myCA.key -sha256 -days 7000 -out myCA.pem
echo "1" > myCA.srl
# SubCA
openssl genrsa -out mySubCA.key 4096
openssl req -new -key mySubCA.key > mySubCA.csr
openssl x509 -req -in mySubCA.csr -out mySubCA.pem -sha256 -extensions v3_ca --CA myCA.pem -days 3650 -CAkey myCA.key -CAcreateserial -CAserial myCA.srl
cat mySubCA.pem myCA.pem > mySubCA-cert-chain.pem
```

We have created 3 Subca:

*   \~/pki/ca.crt and its key ~/pki/ca.key is the main authority of the cluster
*   \~/pki/front-proxy.crt and its key ~/pki/front-proxy.crt
*   \~/pki/etcd/ca.crt and its key ~/pki/etcd/ca.key

### 6.1.1. Deploying the CA

It is important that all nodes trust the new CA.\
Convert the certificate to base64 with `cluster_convert_pem_to_base64 ~/pki/ca.crt`
Add the base64-encoded certificate to the ROOT_CA variable and deploy it with `cluster_deploy_ca_cert`

## 6.2. Control-Plane

Using `oci-manage`

```sh
cluster_init_create_control_plane
```

## 6.3. Name Resolution

During the installation phase, the configuration of CoreDNS is changed.\
One zone `cluster.external` is added. It is used to resolve external IP addresses of services.\
On each node, the systemd-resolved service, which is in charge of system name resolution, is configured to query CoreDNS, so the cluster-internal names can be accessed from the control-plane or the nodes.\
Example `dig +short traefik.kube-traefik.cluster.external` returns the external address of Traefik's LoadBalancer.

## 6.4. Workers

```sh
cluster_init_create_members ; sleep 30 ; cluster_init_create_post_install
# petit bug avec le dashboard si il répond toujours 404 il faut le recréer…
# kubectl delete -n kube-traefik ingressroute.traefik.containo.us/traefik-dashboard ; cluster_init_install_traefik_ingressroute
```

after a few minutes, depending on the number and performance of VMs, the cluster will be up and running! We can check it out...

```sh
kubectl get nodes -o wide
NAME                                         STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
node2.private.tenancy2.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.1.1.14      <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node3.private.tenancy3.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.2.1.60      <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node4.private.tenancy2.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.1.1.142     <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node5.private.tenancy4.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.3.1.222     <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
master.private.tenancy1.oraclevcn.com        Ready    control-plane   3h   v1.27.1   10.0.253.75    <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node6.private.tenancy1.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.0.253.201   <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node7.private.tenancy5.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.4.1.117     <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
node8.private.tenancy1.oraclevcn.com         Ready    <none>          3h   v1.27.1   10.0.253.138   <none>        Ubuntu 22.04.2 LTS   5.15.0-1033-oracle   docker://23.0.4
```

And all pod systems work:

```sh
kubectl get pods -A
NAMESPACE              NAME                                                                 READY   STATUS    RESTARTS       AGE
cert-manager       cert-manager-64f9f45d6f-8x7qw                                        1/1     Running   1 (28m ago)    3h
cert-manager       cert-manager-cainjector-56bbdd5c47-h2fs9                             1/1     Running   1 (27m ago)    3h
cert-manager       cert-manager-webhook-d4f4545d7-qfmmp                                 1/1     Running   1 (27m ago)    3h
kube-system            cilium-6qsgm                                                         1/1     Running   1 (28m ago)    3h
kube-system            cilium-7lqvn                                                         1/1     Running   1 (28m ago)    3h
kube-system            cilium-b52hq                                                         1/1     Running   1 (29m ago)    3h
kube-system            cilium-h8zfq                                                         1/1     Running   1 (30m ago)    3h
kube-system            cilium-kj4bm                                                         1/1     Running   1 (28m ago)    3h
kube-system            cilium-operator-6cff6fb5b7-7zswl                                     1/1     Running   2 (146m ago)   3h
kube-system            cilium-tl8w8                                                         1/1     Running   1 (27m ago)    3h
kube-system            cilium-wmc97                                                         1/1     Running   1 (27m ago)    3h
kube-system            cilium-wzs5v                                                         1/1     Running   1 (146m ago)   3h
kube-system            coredns-787d4945fb-l24v7                                             1/1     Running   1 (146m ago)   3h
kube-system            coredns-787d4945fb-vrgq9                                             1/1     Running   1 (146m ago)   3h
kube-system            etcd-oci-master.private.kerbraoci.oraclevcn.com                      1/1     Running   1 (146m ago)   3h
kube-system            kube-apiserver-oci-master.private.kerbraoci.oraclevcn.com            1/1     Running   1 (146m ago)   3h
kube-system            kube-controller-manager-oci-master.private.kerbraoci.oraclevcn.com   1/1     Running   1 (146m ago)   3h
kube-system            kube-scheduler-oci-master.private.kerbraoci.oraclevcn.com            1/1     Running   1 (146m ago)   3h
kube-traefik           traefik-d65c6d5cd-d8w4j                                              1/1     Running   1 (28m ago)    3h
kubernetes-dashboard   dashboard-metrics-scraper-7bc864c59-d9dqf                            1/1     Running   1 (28m ago)    3h
kubernetes-dashboard   kubernetes-dashboard-7bff9cc896-l8pkd                                1/1     Running   1 (29m ago)    3h
```

## 6.5. Clearing the cluster and reinstalling the cluster

We're in a lab, so we have to do some testing, it's very easy to completely erase the cluster and put it back in the initial configuration. Two steps are required:

### 6.5.1. Erasure

```sh
cluster_reset_members
# eventuellement une fois les membres disponibles
cluster_reset_storage
# control_plane
cluster_reset_control_plane
```

### 6.5.2. Resettlement

Remember to choose the persistence backend which is openEbs by default.\
To use Longhorn you need to change the variable: `STORAGE_BACKEND="longhorn"`

```sh
rm -f ~/.kube/config
sudo rm -f /root/.kube/config
cluster_init_get_cilium_cli
cluster_init_create_control_plane; sleep 30; cluster_init_create_members ; sleep 30 ; cluster_init_create_post_install
# si besoin
cluster_init_create_post_install_grafana
```

## 6.6. Persistent storage

There are several solutions.

### 6.6.1. Longhorn

If your nodes are strong enough [Longhorn](https://longhorn.io/) works wonderfully. It only really works properly if all nodes have at least 4GB of RAM.\
Otherwise, nodes with little memory collapse and the cluster suffers.\
To activate Longhorn:

```sh
cluster_init_install_longhorn
cluster_init_install_longhorn_ingress
```

### 6.6.2. OpenEBS/jiva

It's a lighter solution but without Longhorn's beautiful UI.\
It is necessary to mount the storages in /storage on the members that have block storage.

```sh
cluster_init_install_openebs
```

## 6.7. Certificate Manager

Since we have our own CA, cert-manager is automatically deployed during the post-installation phase.\
This allows certificates to be created automatically.\
This is very useful for generating certificates from Ingress -the incoming https routes in the cluster-\
To automatically create a certificate for the monhote.example.org host that will be stored in the myhoste-cert secret:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: monhote-cert
  namespace: default
  labels:
     k8s-app: monapp
spec:
  subject:
      organizations: 
        - macompagnie
  commonName: monhote.example.org
  dnsNames: [monhote.example.org]
  secretName: monhote-certs
  issuerRef:
    name: company-ca-issuer
    kind: ClusterIssuer
```

To have the Ingress automatically create its certificate to access the myservice and expose it as a https://monhote.example.com/:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: company-ca-issuer
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
  creationTimestamp: "2023-04-07T05:27:16Z"
  name: monhote-ingress
  namespace: default
spec:
  rules:
  - host: monhote.example.org
    http:
      paths:
      - backend:
          service:
            name: monservice
            port:
              name: http
        path: /
        pathType: Prefix
  tls:
  - hosts: [monhote.example.org]
    secretName: monhote-cert
```

## 6.8. Openness to the outside world

By default, all nodes host a proxy [Haproxy](https://www.haproxy.org/). This relays port 443 of the Traefik service on the local interfaces. This makes it possible to have a basic load balancer open to the outside.\
To change the configuration, you need to edit the `/etc/haproxy/haproxy.cfg` of the control-plane and then deploy it to the entire cluster:

```sh
cluster_deploy_haproxy_config_on_members
```

Setting up a port is simple:

    frontend traefik
            bind :443
            default_backend k8s-traefik 

    backend k8s-traefik
            server site traefik.kube-traefik.svc.cluster.local:443 resolvers dns check inter 1000

*   `traefik.kube-traefik.svc.cluster.local`
    *   `k8s-traefik` is a simple label
    *   `traefik` is the internal DNS name of a service
    *   `kube-traefik` its namespace
    *   `443` is the TCP port.

## 6.9. Access to dashboards

On your DNS point `TRAEFIK_DASHBOARD_DNS_NAMES`, `HUBBLE_DASHBOARD_DNS_NAMES` and `DASHBOARD_DNS_NAMES` to the IP addresses of the nodes you open to the outside (one is sufficient).
Note that `TRAEFIK_DASHBOARD_DNS_NAMES`, `HUBBLE_DASHBOARD_DNS_NAMES` and `DASHBOARD_DNS_NAMES` of the file `oci-manage-config.sh` are plural. Indeed, these are bash arrays that allow you to define several DNS names, so for example you can point to `dashboard.domaine.prive` to the IP address visible from inside the lab, and `dashboard.domaine.com` to the IP address visible from the Internet. Traefik will accept both names. The SSL certificate will be valid for both names.\
Your cluster's dashboards can be accessed using these names:

*   `https://TRAEFIK_DASHBOARD_DNS_NAMES/dashboard/` (login TRAEFIK_ADMIN/TRAEFIK_ADMIN_PASSWORD)
*   `https://HUBBLE_DASHBOARD_DNS_NAMES` (login TRAEFIK_ADMIN/TRAEFIK_ADMIN_PASSWORD)
*   `https://DASHBOARD_DNS_NAMES` (login using the token obtained with dashboard_get_token)
*   `https://LONGHORN_DASHBOARD_DNS_NAMES` (login TRAEFIK_ADMIN/TRAEFIK_ADMIN_PASSWORD)

## 6.10. Grafana

### 6.10.1. Local Prometheus and Grafana Instance

If you need a monitoring solution, a Prometheus and Grafana stack can be installed in the cluster.\
`cluster_init_create_post_install_prometheus`\
Note the password indicated, it allows you to connect to the local instance via https://prometheus.domain.org with the following login:

*   apikey
*   Password displayed
    Please note that this password cannot be retrieved and it changes each time the function is executed.\
    You can access the Prometheus https://prometheus.domain.org and Grafana instance https://grafana.domain.org with the global admin login/password

### 6.10.2. Free Hosted Instance

If you need it, you can automatically link your lab cluster to a free instance [Grafana](https://grafana.com/)\
Adjust the values

```sh
GRAFANA_PROMETHEUS_USERNAME="123456"
GRAFANA_PROMETHEUS_PASSWORD="MTFhM2UyMjkwODQzNDliYzI1ZDk3ZTI5MzkzY2VkMWQgIC0K"
GRAFANA_LOGS_USERNAME="654321"
GRAFANA_LOGS_PASSWORD="MTFhM2UyMjkwODQzNDliYzI1ZDk3ZTI5MzkzY2VkMWQgIC0K"
```

the values are available in the Home/Administration/Data sources section of Grafana.

```sh
cluster_init_create_post_install_grafana_v3 install
```

<img width="1916" alt="grafana" src="https://user-images.githubusercontent.com/6966689/230726015-9a90ca9c-e01d-42d0-b693-03daa665b5c0.png">

To erase it

```sh
cluster_init_create_post_install_grafana_v3 delete
```

## 6.11. Local Container Registry

CI/CD is good, but in development it can take a long time.\
A local registry can be handy!\
To install the registry:

### 6.11.1. Create a specific name resolution:

Locate the IP address of the traefik load balancer with `cluster_get_traefik_lb_ip`  Here is 172.31.255.49 and add the hosts section in the Coredns configuration:

```sh
kubectl edit configmap coredns -n kube-system
```

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
        ########## ajout de la propriété hosts
        hosts {
          172.31.255.49 docker-registry.local
          fallthrough
        }
        ##########
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2023-04-15T12:59:35Z"
  name: coredns
```

    dev_install_local_registry

### 6.11.2. To add an image:

```sh
docker push docker-registry.local/cert-manage-webhook-oci:1.3.0.2
#et l'utiliser
helm install --namespace cert-manager cert-manager-webhook-oci deploy/cert-manager-webhook-oci --set image.repository=docker-registry.local/cert-manage-webhook-oci --set image.tag=1.3.0.2
```

### 6.11.3. To uninstall the local registry:

    dev_uninstall_local_registry

### 6.11.4. User Interface

Ingress are defined by the variable DOCKER_REGISTRY_UI_DNS_NAMES

## 6.12. Letsencrypt

### 6.12.1. Oracle OCI DNS01

#### 6.12.1.1. Installation

To create two ClusterIssuers called letstencrypt-oci and letsentrypt-staging-oci (for testing purposes), you need to complete the OCI_\* variables.\
Then install the webhook `cluster_init_install_oci_dns_issuer`.

#### 6.12.1.2. Usage

To create a certificate *Staging*

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test.myocihostedzone.org
  namespace: cert-manager
spec:
  commonName: test.myocihostedzone.org
  dnsNames:
    - ttest.myocihostedzone.org
  issuerRef:
    name: letsencrypt-staging-oci
    kind: ClusterIssuer
  secretName: test.myocihostedzone.org
```

#### 6.12.1.3. Uninstalling

```sh
cluster_init_remove_oci_dns_issuer
```

### 6.12.2. Azure DNS

First of all, the cli needs to be installed

#### 6.12.2.1. Installing the Azure CLI

```sh
azure_install_cli
```

#### 6.12.2.2. Installation

```sh
az login --use-device-code
AZURE_CERT_MANAGER_NEW_SP_NAME=kube-cluster-azure-sp
# This is the name of the resource group that you have your dns zone in.
AZURE_DNS_ZONE_RESOURCE_GROUP=AZURE_DNS_ZONE_RESOURCE_GROUP
# The DNS zone name. It should be something like domain.com or sub.domain.com.
AZURE_DNS_ZONE=example.org
DNS_SP=$(az ad sp create-for-rbac --name $AZURE_CERT_MANAGER_NEW_SP_NAME --output json)
AZURE_CERT_MANAGER_SP_APP_ID=$(echo $DNS_SP | jq -r '.appId')
AZURE_CERT_MANAGER_SP_PASSWORD=$(echo $DNS_SP | jq -r '.password')
AZURE_TENANT_ID=$(echo $DNS_SP | jq -r '.tenant')
AZURE_SUBSCRIPTION_ID=$(az account show --output json | jq -r '.id')
AZURE_DNS_ID=$(az network dns zone show --name $AZURE_DNS_ZONE --resource-group $AZURE_DNS_ZONE_RESOURCE_GROUP --query "id" --output tsv)
az role assignment delete --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role Contributor
az role assignment create --assignee $AZURE_CERT_MANAGER_SP_APP_ID --role "DNS Zone Contributor" --scope $AZURE_DNS_ID
```

Update the variables AZURE_DNS_ZONE, AZURE_CERT_MANAGER_SP_APP_ID, AZURE_CERT_MANAGER_SP_PASSWORD, AZURE_TENANT_ID, AZURE_DNS_ID, and AZURE_SUBSCRIPTION_ID in your oci-manage or oci-manage-config.sh.

```sh
cluster_init_azure_dns_issuer
```

#### 6.12.2.3. Usage

To create a certificate *Staging*

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test.example.org
  namespace: cert-manager
spec:
  commonName: test.example.org
  dnsNames:
    - test.example.org
  issuerRef:
    name: letsencrypt-staging-azure
    kind: ClusterIssuer
  secretName: test.example.org
```

#### 6.12.2.4. Uninstalling

```sh
cluster_reset_remove_azure_dns_issuer
```

### 6.12.3. Cloudflare CNAME Automatic Deployment

#### 6.12.3.1. Installation

Setting Variables `CF_API_KEY` `CF_API_EMAIL` and `CF_DOMAINS`

```sh
cluster_cloudflare_external_dns
```

#### 6.12.3.2. Example of use

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install --namespace monsite --create-namespace monsite bitnami/wordpress --set volumePermissions.enabled=true,image.debug=true
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wp-ingress
  namespace: monsite
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cloudflare
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    external-dns.alpha.kubernetes.io/target: ha.cluster.fqdn
    external-dns.alpha.kubernetes.io/hostname: monsite.example.org
    external-dns.alpha.kubernetes.io/ttl: "86400"
spec:
  ingressClassName: traefik
  rules:
  - host: monsite.example.org
    http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: monsite-wordpress
              port:
                number: 80
  tls:
  - hosts: [monsite.example.org]
    secretName: monsite-tls-cert
```

#### 6.12.3.3. Uninstalling

```sh
cluster_cloudflare_external_dns delete
```

## 6.13. Helm-Dashboard

[Komodor](https://komodor.io) provides a great tool for managing Helm charts in its cluster. Unfortunately, they don't stream ARM64-compatible Docker images.\
We have therefore adapted a [version](https://github.com/highcanfly-club/helm-dashboard.git).

```sh
helm repo add highcanfly https://helm-repo.highcanfly.club/
helm repo update
helm upgrade --namespace helm-dashboard --create-namespace --install helm-dashboard highcanfly/helm-dashboard
```

To deploy it with `oci-manage`:\
Edit the variable `HELM_DASHBOARD_DNS_NAMES` then run:\\

```sh
cluster_install_helm_dashboard
cluster_install_helm_dashboard_ingress
```

The dashboard can then be used on the DNS names configured in `HELM_DASHBOARD_DNS_NAMES`

## 6.14. Wireguard

A mesh network with Wireguard makes it possible to bypass the Oracle LPG link and possibly to open the cluster outside the Oracle infrastructure, the metric of each route is set to 100 to favor routes via local peering gateways

### 6.14.1. Initialization

```sh
wg_meshconf_init
```

### 6.14.2. Adding a Node

```sh
wg_meshconf_addpeer oci-nodeN oci-nodeN.example.com 51820
```

### 6.14.3. View Nodes

```sh
wg_meshconf_showpeers
```

<img width="874" alt="wg_meshconf" src="https://user-images.githubusercontent.com/6966689/233775674-08ad11b9-66fb-4f08-a6d7-1fd55549803f.png">

### 6.14.4. Deploying Nodes

```sh
wg_meshconf_deploy_config
```

## 6.15. File `README.md` multilingual

Machine translation is performed by Azure with `markdown-translator`

```sh
npm install markdown-translator -g
md-translator set --key d5a37213c945793e297f0f609e293f99
md-translator set --region westeurope
md-translator translate --src README.fr-FR.md --dest README.md --from fr-FR --to en-US
#update manually the toc
```

## 6.16. Bird on the control-plane

TODO

```sh
sudo apt install bird
sudo systemctl enable bird
sudo birdc configure
```

    router id $CONTROL_PLANE_IP;
    define my_as=$CLUSTER_AS;
    protocol direct {
            interface "ens1*", "cilium*", "lxc*";
    }
    protocol kernel {
            persist off;
            scan time 20;
            learn;
            import all;
            export none;
    }
