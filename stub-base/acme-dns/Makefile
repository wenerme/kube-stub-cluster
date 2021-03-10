
acme-dns.ignored.json: build.sh $(wildcard *.acme-dns.ignored.json)
	sh ./build.sh

# generate secret and seal
acme-dns.secret.yaml: acme-dns.ignored.json
	kubectl create secret generic acme-dns --dry-run=client -n cert-manager --from-file=acme-dns.json=acme-dns.ignored.json -o yaml > acme-dns.secret.yaml
	cp acme-dns.secret.yaml ..
	cd .. && make seal
	[ -e letsencrypt-acme-dns.ci.yaml ] cp letsencrypt-acme-dns.ci.yaml ../templates
