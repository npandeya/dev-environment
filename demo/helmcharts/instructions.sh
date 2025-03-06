helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab --create-namespace \
  -f gitlab-values.yaml

# VErify 
kubectl get pods -n gitlab
kubectl get svc -n gitlab
kubectl get ingress -n gitlab

# Sonarqube
https://github.com/SonarSource/helm-chart-sonarqube/tree/master/charts/sonarqube

helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube # If you dont have permissions to create the namespace, skip this step and replace all -n with an existing namespace name.
export MONITORING_PASSCODE="yourPasscode"

helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube --set monitoringPasscode=$MONITORING_PASSCODE,community.enabled=true -f sonar-values.yaml