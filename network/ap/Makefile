IMAGE=mak3r/hostapd
build :
	docker build -t $(IMAGE):local .

TAG="latest"
publish : build
	docker tag $(IMAGE):local $(IMAGE):$(TAG)
	docker push $(IMAGE):$(TAG)

test : build
	docker run -it --rm --name hostapd $(IMAGE):local