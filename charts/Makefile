REPO=sparkle

publish:
	mkdir -p charts
	helm package -u -d charts `ls */Chart.yaml | xargs dirname`
	ls charts/* | xargs -I {} helm push {} ${REPO}
