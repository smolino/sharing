#!/bin/bash
#  Author
#  Sergio Molino
#
#  This script install Entando application on EKS
#
namespace=$1
appname=$2

if [[ -z "$namespace" ]]; then
        echo "Use "$(basename "$0")" NAMESPACE";
        exit 1;
fi
if [[ -z "$appname" ]]; then
        echo "Use "$(basename "$0")" APPNAME";
        exit 1;
fi
echo ""
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Installing ingress"
echo ""
echo "##################################################################################"
echo "##################################################################################"
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.2/deploy/static/provider/aws/deploy.yaml
# Old version not supported anymore / does not work with entando.ingress.class: 'nginx'
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/aws/deploy.yaml
# This works
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.3/deploy/static/provider/aws/deploy.yaml
# sleep 30
echo ""
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Creating Namespace $namespace"
echo ""
echo "##################################################################################"
echo "##################################################################################"
kubectl create namespace $namespace


echo ""
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Applying Config Map"
echo ""
echo "##################################################################################"
echo "##################################################################################"

echo -e "
kind: ConfigMap
apiVersion: v1
metadata:
  name: entando-operator-config
  namespace: $namespace
data:
  entando.pod.completion.timeout.seconds: '2000'
  entando.pod.readiness.timeout.seconds: '2000'
  entando.requires.filesystem.group.override: 'true'
  entando.ingress.class: 'nginx'" | kubectl apply -f -

echo ""
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Creating Cluster Resources"
echo ""
echo "##################################################################################"
echo "##################################################################################"

kubectl apply -f https://raw.githubusercontent.com/entando/entando-releases/v7.2.0/dist/ge-1-1-6/namespace-scoped-deployment/cluster-resources.yaml

echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Creating Namespace Resources"
echo ""
echo "##################################################################################"
echo "##################################################################################"

kubectl apply -n $namespace -f https://raw.githubusercontent.com/entando/entando-releases/v7.2.0/dist/ge-1-1-6/namespace-scoped-deployment/namespace-resources.yaml

#kubectl apply -n $namespace -f /home/{{ username }}/namespace-resources_custom.yaml
#kubectl create secret generic mysql-secret --from-literal username=automation --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic oracle-secret --from-literal username=automation --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic postgres-secret --from-literal username=automation --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic default-sso-in-namespace-db-secret --from-literal username=automationsso --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic $appname-portdb-secret --from-literal username=automationport --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic $appname-servdb-secret --from-literal username=automationserv --from-literal password=myP4ssw0rd -n $namespace
#kubectl create secret generic $appname-dedb-secret --from-literal username=automationecr --from-literal password=myP4ssw0rd -n $namespace
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Deploying Applicaton $appname"
echo ""
echo "##################################################################################"
echo "##################################################################################"
sleep 10
kubectl get svc -n traefik | grep LoadBalancer | awk '{print $4}' | while read HOST;do
echo -e "
apiVersion: entando.org/v1
kind: EntandoApp
metadata:
  namespace: $namespace
  name: $appname
spec:
  environmentVariables:
  dbms: postgresql
  ingressHostName: entando.172.28.225.108.nip.io
  standardServerImage: tomcat
  replicas: 1" | kubectl apply -f -; done
echo ""
echo "##################################################################################"
echo "##################################################################################"
echo ""
echo "Namespace $namespace is created and $appname application is deploying"
echo "Wait around 10 minutes, when application is deployed it is available at:"
echo ""
# kubectl get svc -n ingress-nginx | grep LoadBalancer | awk '{print $4}' |while read HOST;do
echo "http://entando.172.28.225.108.nip.io/app-builder/"
echo ""
echo "##################################################################################"
echo "##################################################################################"
sleep 350
# sleep 600
