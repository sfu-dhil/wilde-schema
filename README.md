# Lyon in Mourning Project Schema

This repository contains the schema and documentation for the Wilde Trials International News Archive, an HTML-encoded collection of news reports concerning the trials of Oscar Wilde in 1895. The project is led by Dr. Colette Colligan (SFU) with support provided by the Digital Humanities Innovation Lab (SFU Library).

The schema and documentation is encoded in P5 TEI XML and can be found in `schema/reports.odd`. The associated RelaxNG schema (with embedded schematron) is in `schema/reports.rng`.

The root `build.xml` file is an ant build script that:

* Creates the documentation from the TEI ODD file by running the ODD through a set of the TEI Stylesheets and some custom processing (`ant docs`)

There are two GitHub actions associated with the repository, which handle automated deployment of the docs and the framework. Each job is run on any `push` event.

The [documentation](https://sfu-dhil.github.io/wilde-schema/public/index.html) is available in GitHub Pages.
