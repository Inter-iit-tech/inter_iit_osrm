bengaluru-clip:
	./clipper.exe southern-zone-latest.osm.pbf -b=77.50,12.88,77.68,13.05 --out-pbf -o=clip.osm.pbf

get-map:
	wget https://download.geofabrik.de/asia/india/southern-zone-latest.osm.pbf

build-ch:
	docker build --memory="1G" --cpu-quota=2 -t osrm-ch -f ch/Dockerfile.dev .

build-mld:
	docker build --memory="1G" --cpu-quota=2 -t osrm-mld -f mld/Dockerfile.dev .

et:
	mkdir t_extract
	cp ./clip.osm.pbf ./t_extract
	docker run --memory="1G" --cpus=2 --rm -t -v "${PWD}:/data" ghcr.io/project-osrm/osrm-backend osrm-extract -p /opt/car.lua /data/t_extract/clip.osm.pbf
	cp -r ./t_extract/. ./extract
	rm -r t_extract


build-ch-fast:
	docker build -t osrm-ch-fast -f ch/Dockerfile.dev .

build-mld-fast:
	docker build -t osrm-mld-fast -f mld/Dockerfile.dev .

et-fast:
	mkdir t_extract
	cp ./clip.osm.pbf ./t_extract
	docker run --rm -t -v "${PWD}:/data" ghcr.io/project-osrm/osrm-backend osrm-extract -p /opt/car.lua /data/t_extract/clip.osm.pbf
	cp -r ./t_extract/. ./extract
	rm -r t_extract

build:
	$(MAKE) et
	$(MAKE) build-ch
	$(MAKE) build-mld

build-fast:
	$(MAKE) et-fast
	$(MAKE) build-ch-fast
	$(MAKE) build-mld-fast

run:
	docker-compose -f docker-compose.yml up

run-fast:
	docker-compose -f docker-compose-fast.yml up

clean:
	docker-compose rm
	rm -r ./t_extract

clean-hard:
	rm -r ./extract
	mkdir extract
	docker-compose rm




