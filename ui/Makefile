IMAGE=mak3r/turnkey-ui
build :
	docker build -t $(IMAGE):local .

TAG="latest"
publish : build
	docker tag $(IMAGE):local $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)

SHELL = /bin/bash
.ONESHELL:

CUR_DIR = $(shell pwd)

projects.list:
	cat <<- EOF > $(CUR_DIR)/$@
		k3s=Lightweight Kubernetes Cluster
		Rancher=Rancher Management Server
		k3os=An OS optimized for container orchestration
	EOF

ssid.list:
	cat <<- EOF > $(CUR_DIR)/$@
		wifi-none001
		wifi-none002
		wifi-none003
	EOF

test : build projects.list ssid.list
	docker run -it --rm -v /tmp:/tmp -v $(CUR_DIR):/var/lib/rancher/turnkey -v /var/lib/rancher/k3s/server/manifests:/var/lib/rancher/k3s/server/manifests -p 80:80 --name ui --entrypoint /bin/bash $(IMAGE):local