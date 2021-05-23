
love:

sync-stub:
	ls */Chart.yaml */kustomization.yaml | xargs dirname | xargs -n 1 -I {} cp scripts/stub/Makefile '{}'
