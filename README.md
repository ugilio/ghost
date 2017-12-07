[![Build Status](https://www.travis-ci.org/ugilio/ghost.svg?branch=master)](https://www.travis-ci.org/ugilio/ghost)
[![Coverage Status](https://coveralls.io/repos/github/ugilio/ghost/badge.svg?branch=master)](https://coveralls.io/github/ugilio/ghost?branch=master)
[![Coverity Scan Build Status](https://scan.coverity.com/projects/14478/badge.svg)](https://scan.coverity.com/projects/ugilio-ghost)

# Ghost
Ghost is a language for [Timeline-based Planning](https://ugilio.github.io/keen/intro), developed to replace [DDL](https://ugilio.github.io/keen/intro#the-ddl-language). With respect to DDL it tries to be more concise and readable, while also adding new features like generic synchronizations and type inheritance.

This repository contains a ghost-to-ddl command-line compiler, `ghostc`, and an [Eclipse](https://www.eclipse.org) plugin that can be used to ease development of planning domains and problems; the generated ddl files can then be given as input to a planner supported by the [KeeN Environment](https://ugilio.github.io/keen).

The ghost language was designed and implemented by Giulio Bernardi. Currently, the compiler and the Eclipse plugin should be considered *alpha* quality software: any API is subject to change, and the language itself might undergo some (hopefully minor) changes; this also means that bugs and other problems are expected (but if you find any of them, please [report them](https://github.com/ugilio/ghost/issues)). It is Open Source software released under the [Eclipse Public License](https://www.eclipse.org/legal/epl-v10.html).

### Getting Started

* **Eclipse Plugin**: add the update site `https://ugilio.github.io/ghost/update/latest`. Requires Eclipse Neon.3 or better and Java 8
  * Alternative update sites: `https://ugilio.github.io/ghost/update/v0.1.0` for a specific version (replace 0.1.0 with the desired version) or `https://ugilio.github.io/ghost/update/unstable` to use the plugin built from the latest commit made to the `master` branch.
* **Command-line compiler**: download the most appropriate version for your operating system (.zip for Windows, tar.bz2 otherwise) from the [release page](https://github.com/ugilio/ghost/releases/latest), uncompress and run bin/ghostc

Further informations on the [website](https://ugilio.github.io/ghost).

### Building from Source

Clone the repository:
```
git clone https://github.com/ugilio/ghost.git
cd ghost
```

and then build from the `*releng` directory (requires [Maven](https://maven.apache.org/) and Java 8):
```
cd *.releng
mvn package
```
If you also want to run the test suite, do `mvn verify` instead of `mvn package`.

### Developing in Eclipse

- Install Xtext (e.g. via the update site).
- File => Import => Existing Projects into Workspace. Select all projects in the git checkout.
- Eclipse will start spitting out thousands of errors.
- Wait for building to finish, then open Ghost.xtext (.ghost project => src folder => .ghost package).
- Right click somewhere in the file and choose "Run => Generate Xtext Artifacts": tell Eclipse that it's ok to proceed even if the project has errors.
- When building is over, errors should have been resolved.
- If there are still errors related to missing plugin lifecycle mappings, use Quick fix to discover missing m2e connectors, and install the suggested Tycho Project Configurators.

### More Information

* [Website](https://ugilio.github.io/ghost).

* [Language Manual](https://ugilio.github.io/ghost/manual).

* [Introduction to Timeline-based Planning](https://ugilio.github.io/keen/intro).

* [The GHOST language in EBNF form](https://ugilio.github.io/ghost/ghostebnf).
