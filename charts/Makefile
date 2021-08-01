REPO=wener

publish:
	mkdir -p charts
	helm package -u -d charts `ls */Chart.yaml | xargs dirname`
	ls charts/* | xargs -I {} helm push {} ${REPO}

lint:
	ls */Chart.yaml | xargs dirname | xargs -n 1 -I {} helm lint --strict {}
