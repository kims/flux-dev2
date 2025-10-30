#!/bin/bash

# Create app structure
kubectl create ns flux-dev2
kubectl create -f GitRepository.flux-dev2.yaml
kubectl create -f HelmRelease.app2.yaml
kubectl create -f Kustomization.app2.yaml

## Generate and seal secret

rm /tmp/age.*
age-keygen -o /tmp/age.key &> /tmp/age.pub

kubectl delete secret -n flux-dev2 sops-age
kubectl create secret generic sops-age \
  --namespace=flux-dev2 \
  --from-file=age.agekey=/tmp/age.key \
  --type=Opaque


cat > .sops.yaml <<EOF
creation_rules:
  - path_regex: .*\\.yaml$
    encrypted_regex: '^(data|stringData)$'
    age:
      - $(cat /tmp/age.pub | awk '{print $3}')
EOF

PW=$(openssl rand -base64 32)
cat > secrets/secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: flux-dev2
type: Opaque
stringData:
  DB_PASSWORD: ${PW}
EOF

sops --encrypt -i secrets/secret.yaml
