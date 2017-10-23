# IEDB GAZ

This tool builds a view of the [Gazeteer Ontology (GAZ)](http://obofoundry.org/ontology/gaz.html) for use by the [Immune Epitope Database (IEDB)](http://iedb.org). The key modifications are that individual locations are treated as `owl:Class`es, and only a small subset of locations is included.


## Requirements

Most of the work is done using SPARQL INSERT queries. The `Makefile` fetches the required tools:

- `gaz.owl`
- [Blazegraph]()
- [ROBOT](https://github.com/ontodev/robot)

Blazegraph and ROBOT require [Java](https://www.java.com/en/download/help/download_options.xml), and the `Makefile` requires [GNU Make](https://www.gnu.org/software/make/) and standard Unix tools such as `curl` and `sed`.

This will take about 2.5 GB of storage:

- `lib/gaz.owl` ~620MB
- `lib/blazegraph.jar` ~55MB
- `lib/blazegraph.jnl` ~1.5G


## Usage

You run this tool using *two* terminal sessions.

In the first terminal run:

    make run-blazegraph

This will fetch GAZ and Blazegraph, then load GAZ into Blazegraph, and start a local Blazegraph server. It will take a few minutes. When it's ready you'll see a message saying "Go to http://172.16.100.1:9999/blazegraph/ to get started." Opening <http://172.16.100.1:9999/blazegraph/> in your browser will let you query GAZ with SPARQL.

You can stop the Blazegraph server with `Ctrl-C`.

In the second terminal run:

    make

This will run `build.sparql` and put the result in `build/iedb_gaz.owl`. Copy this file to wherever you want to use it.

When you're done, stop the Blazegraph server, and run `make clobber` to delete all the files that were fetched and generated.


## License

Copyright © 2017 James A. Overton

Distributed under the BSD 3-Clause License.
