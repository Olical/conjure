#!/usr/bin/env bash

docker run \
	--name conjure_postgres_db \
	--rm \
	-p 5432:5432 \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=postgres \
	-e POSTGRES_DB=postgres \
	postgres:13
