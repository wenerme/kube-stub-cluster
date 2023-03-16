
forward:
	$(KUBECTL) port-forward svc/argocd-server -n argocd 8443:443
show-password:
	which pbcopy && $(KUBECTL) get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
wait:
	$(KUBECTL) get --namespace argocd deployments.apps argocd-server -w
watch:
	$(KUBECTL) kubectl get events --namespace argocd -w
