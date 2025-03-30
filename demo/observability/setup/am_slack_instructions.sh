k get secret alertmanager-kube-prom-stack-kube-prome-alertmanager -o yaml

base64 decode the content and add the content of the alertmanager.yaml

# Reencode and patch
kubectl create secret generic alertmanager-kube-prom-stack-kube-prome-alertmanager \
  --from-file=alertmanager.yaml=alertmanager.yaml \
  -n observability --dry-run=client -o yaml | kubectl apply -f -
