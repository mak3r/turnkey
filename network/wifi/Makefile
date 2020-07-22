IMAGE=wifi
REPOSITORY=mak3r
build :
	docker build -t $(REPOSITORY)/$(IMAGE):local .

TAG="latest"
publish : build
	docker tag $(REPOSITORY)/$(IMAGE):local $(REPOSITORY)/$(IMAGE):$(TAG)
	docker push $(REPOSITORY)/$(IMAGE):$(TAG)

test : build
	docker run -it --rm --net=host --pid=host -v /tmp:/tmp -v /var/lib/rancher/turnkey:/var/lib/rancher/turnkey --name $(IMAGE) $(REPOSITORY)/$(IMAGE):local