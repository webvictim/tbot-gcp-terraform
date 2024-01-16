# tbot-gcp-terraform

Example demonstrating how to run Teleport Terraform provider inside GKE with Workload Identity and Teleport Machine ID

## Add bot and role to Teleport cluster
```bash
# Create a Teleport join token called "tbot-gcp-example"
tctl create -f teleport/bot-token.yaml
# Creates a Teleport role called "tbot-terraform"
tctl create -f teleport/bot-role.yaml
# Create a Teleport Machine ID bot called "tbot-gcp-example"
# When this bot joins the cluster (with the "tbot-gcp-example" token) it will be granted the "tbot-terraform" role
tctl bots add gcp-example --token tbot-gcp-example --roles tbot-terraform
```

## Add ConfigMaps to Kubernetes cluster to be used by tbot
```bash
# Create a ConfigMap containing the tbot runtime config to join the cluster and output an identity file
kubectl create configmap tbot-config --from-file=tbot/tbot-config.yaml
# Create a ConfigMap containing the Terraform code
# This includes a provider.tf config which uses our tbot identity file
kubectl create configmap terraform-code --from-file=terraform
```

## Grant GCP permissions
```bash
# Create matching GCP IAM Service Account
gcloud iam service-accounts create tbot-terraform-sa --project=tbotexample-305123
# Create policy binding between GCP IAM Service Account and "Service Account User" role
gcloud projects add-iam-policy-binding tbotexample-305123 --member "serviceAccount:tbot-terraform-sa@tbotexample-305123.iam.gserviceaccount.com" --role "roles/iam.serviceAccountUser"
# Create policy binding between Kubernetes ServiceAccount and GCP IAM Service Account
gcloud iam service-accounts add-iam-policy-binding tbot-terraform-sa@tbotexample-305123.iam.gserviceaccount.com --role roles/iam.workloadIdentityUser --member "serviceAccount:tbotexample-305123.svc.id.goog[default/tbot-terraform-sa]"
```

## Create Kubernetes ServiceAccount
```bash
# Create Kubernetes ServiceAccount to be used by the Pod
# This will be referred to as [default/tbot-terraform-sa]
kubectl --namespace default create serviceaccount tbot-terraform-sa
# Annotate the Kubernetes ServiceAccount with the GCP IAM Service Account address
kubectl --namespace default annotate serviceaccount tbot-terraform-sa iam.gke.io/gcp-service-account=tbot-terraform-sa@tbotexample-305123.iam.gserviceaccount.com
```

## Create pod
```bash
# Create a Pod
# This Pod first runs an InitContainer with tbot in oneshot mode outputting an identity
# It then runs Terraform to apply all declared resources using this oneshot identity
kubectl apply -f kubernetes/pod.yaml
```