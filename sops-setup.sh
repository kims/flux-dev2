#!/bin/bash

rm /tmp/age.*
age-keygen -o /tmp/age.key &> /tmp/age.pub

kubectl delete secret -n flux-system sops-age
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/tmp/age.key \
  --type=Opaque


cat > .sops.yaml <<EOF
creation_rules:
  - path_regex: .*\\.yaml$
    encrypted_regex: '^(data|stringData)$'
    age:
      - $(cat /tmp/age.pub)
EOF

PW=$(openssl rand -base64 32)
cat > secrets/secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
  namespace: dev1
type: Opaque
stringData:
  DB_PASSWORD: ${PW}
EOF

sops --encrypt -i secrets/secret.yaml
