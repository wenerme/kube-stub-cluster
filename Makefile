
love:

sync-stub:
	ls */Chart.yaml */kustomization.yaml | xargs dirname | xargs -n 1 -I {} cp scripts/stub/Makefile '{}'

verify:
	ls */Chart.yaml */kustomization.yaml | xargs dirname | xargs -n 1 -I {} bash -c 'cd {}; make verify'

helm-up:
	ls */Chart.yaml | xargs dirname | xargs -n 1 -I {} helm dep up {}
