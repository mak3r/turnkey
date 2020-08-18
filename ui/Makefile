IMAGE=mak3r/turnkey-ui
build :
	docker build -t $(IMAGE):local .

TAG="latest"
publish : build
	docker tag $(IMAGE):local $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)

SHELL = /bin/bash
.ONESHELL:

projects.list:
	cat <<- EOF > /var/lib/rancher/turnkey/$@
		['k3s', 'Lightweight Kubernetes Cluster']
		['Rancher', 'Rancher Management Server']
		['k3os', 'An OS optimized for container orchestration']
	EOF

test : build projects.list
	docker run -it --rm -v /tmp:/tmp -v /var/lib/rancher/turnkey:/var/lib/rancher/turnkey -v /var/lib/rancher/k3s/server/manifests:/var/lib/rancher/k3s/server/manifests -p 80:80 --name ui --entrypoint /bin/bash $(IMAGE):local