FROM ghcr.io/project-osrm/osrm-backend:latest

WORKDIR /

COPY ./motorcycle.lua ./opt
