#!/bin/bash

docker run --mount type=bind,src="$(pwd)",target="/workdir" polprzewodnikowy/sc64env:0.9 /bin/bash -c "make clean all"
