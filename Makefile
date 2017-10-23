# IEDB GAZ Makefile
#
# Fetches tools and builds an IEDB-centric version of the GAZ ontology.
# Most of the work is done in the SPARQL file `build.sparql`.
# We use Blazegraph to run SPARQL, and ROBOT to convert to OWL.


### Configuration
#
# These are standard options to make Make sane:
# <http://clarkgrubb.com/makefile-style-guide#toc2>

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:


### General Tasks

all: build/iedb_gaz.owl

clean:
	rm -rf build rules.log

clobber: clean
	rm -rf lib


### Fetch GAZ

lib:
	mkdir -p $@

lib/gaz.owl: | lib
	curl -L -o $@ http://purl.obolibrary.org/obo/gaz.owl


## Fetch ROBOT

lib/robot.jar: | lib
	curl -L -o $@ https://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot.jar

ROBOT := java -jar lib/robot.jar


## Fetch and run Blazgraph

lib/blazegraph.jar: | lib
	curl -o $@ -L https://sourceforge.net/projects/bigdata/files/latest/download

lib/blazegraph.jnl: lib/blazegraph.jar blazegraph.properties lib/gaz.owl
	java -Xmx4g -cp lib/blazegraph.jar com.bigdata.rdf.store.DataLoader -defaultGraph "http://www.iedb.org/dev/gaz" blazegraph.properties lib/gaz.owl

.PHONY: run-blazegraph
run-blazegraph: lib/blazegraph.jar lib/blazegraph.jnl
	cd lib && java -server -Xmx4g -jar blazegraph.jar


## Build

build:
	mkdir -p $@

build/iedb_gaz.ttl: build.sparql | build
	curl -X POST http://localhost:9999/blazegraph/sparql --data-urlencode "update=$$(cat $<)"
	curl -X POST http://localhost:9999/blazegraph/sparql --data-urlencode "query=CONSTRUCT FROM <http://www.iedb.org/dev/iedb-gaz> WHERE {?s ?p ?o}" -H 'Accept:text/turtle' \
	| sed 's!VERSION!$(shell date +'%Y-%m-%d')!' \
	> $@

build/iedb_gaz.owl: build/iedb_gaz.ttl | lib/robot.jar
	$(ROBOT) convert -i $< -o $@

