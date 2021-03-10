
acme-dns.ignored.json:
	[ -e acme-dns.ignored.json ] || curl -X POST https://auth.acme-dns.io/register | jq > acme-dns.ignored.json

# generate secret and seal
acme-dns.secret.yaml:
	kubectl create secret generic acme-dns --dry-run=client -n cert-manager --from-file=acme-dns.json=acme-dns.ignored.json -o yaml > acme-dns.secret.yaml
	cp acme-dns.secret.yaml ..
	cd .. && make seal
