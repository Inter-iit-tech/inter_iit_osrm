bengaluru-clip:
	./clipper.exe southern-zone-latest.osm.pbf -b=77.374,12.792,77.8,13.162 --out-pbf -o=clip.osm.pbf

build-ch:
	docker build -t osrm-ch -f ch/Dockerfile.dev .

build-mld:
	docker build -t osrm-mld -f mld/Dockerfile.dev .

et:
	mkdir t_extract
	cp ./clip.osm.pbf ./t_extract
	docker run --rm -t -v "${PWD}:/data" ghcr.io/project-osrm/osrm-backend osrm-extract -p /opt/car.lua /data/t_extract/clip.osm.pbf
	cp -r ./t_extract/. ./extract
	rm -r t_extract

build:
	$(MAKE) et
	$(MAKE) build-ch
	$(MAKE) build-mld

run-dev:
	docker-compose -f docker-compose.yml up

clean:
	docker-compose rm

clean-hard:
	rm -r ./extract
	mkdir extract
	docker-compose rm




