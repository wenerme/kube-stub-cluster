AUTH_JSON=auth.ignored.json
NAME=dockerconfig

dockerconfig.ignored.json: $(AUTH_JSON)
	AUTH_JSON=$(AUTH_JSON) node ./dockerconfig.js > dockerconfig.ignored.json

dockerconfig.secret.yaml: dockerconfig.ignored.json
	kubectl create secret generic $(NAME) \
		--dry-run=client -o yaml --type=kubernetes.io/dockerconfigjson \
		--from-file=.dockerconfigjson=dockerconfig.ignored.json -o yaml > dockerconfig.secret.yaml
	cp dockerconfig.secret.yaml ..
	cd .. && make seal
