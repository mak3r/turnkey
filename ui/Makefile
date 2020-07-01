IMAGE=mak3r/turnkey-ui
build :
	docker build -t $(IMAGE):local .

TAG="latest"
publish : build
	docker tag $(IMAGE):local $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)

test : build
	docker run -it --rm -v /tmp:/var/lib/rancher/turnkey -v /var/lib/rancher/k3s/server/manifests:/var/lib/rancher/k3s/server/manifests -p 80:80 --name ui $(IMAGE):local