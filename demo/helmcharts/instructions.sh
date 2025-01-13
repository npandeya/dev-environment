helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab --create-namespace \
  -f gitlab-values.yaml

# VErify 
kubectl get pods -n gitlab
kubectl get svc -n gitlab
kubectl get ingress -n gitlab