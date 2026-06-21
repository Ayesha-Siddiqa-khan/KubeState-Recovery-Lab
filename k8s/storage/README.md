# AWS EBS CSI Driver

Terraform attaches `var.ebs_csi_driver_policy_arn` to the self-managed Kubernetes EC2 node role. Install the self-managed EBS CSI driver before applying StatefulSets that use the `gp3` StorageClass.

```bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --version 2.27.0 \
  --set controller.tolerations[0].key=CriticalAddonsOnly \
  --set controller.tolerations[0].operator=Exists \
  --set controller.tolerations[1].key=node-role.kubernetes.io/control-plane \
  --set controller.tolerations[1].operator=Exists \
  --set controller.tolerations[1].effect=NoSchedule \
  --set controller.tolerations[2].key=node-role.kubernetes.io/master \
  --set controller.tolerations[2].operator=Exists \
  --set controller.tolerations[2].effect=NoSchedule \
  --set controller.tolerations[3].effect=NoExecute \
  --set controller.tolerations[3].operator=Exists \
  --set controller.tolerations[3].tolerationSeconds=300 \
  --set node.tolerateAllTaints=true \
  --wait --timeout 5m
kubectl apply -f k8s/storage/gp3-storageclass.yaml
kubectl get storageclass
```

The control-plane tolerations are intentional for this lab because early deploys may run before a worker node has joined.

For production, prefer a dedicated workload identity strategy over broad node instance-profile access.
