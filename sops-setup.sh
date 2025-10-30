#rm /tmp/age.*
#age-keygen -o /tmp/age.key &> /tmp/age.pub

kubectl delete secret -n flux-system sops-age

kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=/tmp/age.key \
  --type=Opaque

