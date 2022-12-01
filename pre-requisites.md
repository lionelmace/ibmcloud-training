# Pre-Requisites

Duration: Plan 2h to install all those pre-requisites

1. Bring your own laptops

1. Do you have access to internet?

    Try those links: https://hub.docker.com/signup,  http://cloud.ibm.com, https://cloud.ibm.com/shell

1. Assurez vous d’avoir un IBM ID https://www.ibm.com/account/us-en/signup/register.htmlMerci de nous communiquer votre IBM ID.

1. Sign for a Docker Account - Required for Docker Lab
https://hub.docker.com/signup 

1. Installer docker CE (Community Edition)

* Mac https://docs.docker.com/docker-for-mac/
* Windows 10 https://docs.docker.com/docker-for-windows/
* Windows 7 (Docker Toolbox) https://docs.docker.com/toolbox/toolbox_install_windows/
* Linux https://docs.docker.com/install/linux/docker-ce/ubuntu/

Test:

a/ docker -v
b/ Test Proxy
docker run hello-worl

1. Installer la ligne de commande IBM Cloud: ibmcloud

https://github.com/IBM-Cloud/ibm-cloud-cli-release/releases

1. Installer les plugins IBM Cloud

    ```sh
    ibmcloud plugin install kubernetes-service
    ibmcloud plugin install container-registry
    ibmcloud plugin install infrastructure-service
    ```

1. Installer la ligne de commande de Kubernetes: kubectl

https://kubernetes.io/docs/tasks/tools/install-kubectl

1. Install la ligne de commande OpenShift : oc

https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.11.13/

1. Install la ligne de commande Git : git

https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
