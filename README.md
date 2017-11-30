[![Build Status](https://www.travis-ci.org/ugilio/ghost.svg?branch=master)](https://www.travis-ci.org/ugilio/ghost)

# Ghost
Ghost is a language for [Timeline-based Planning](https://ugilio.github.io/keen/intro), developed to replace [DDL](https://ugilio.github.io/keen/intro#the-ddl-language). With respect to DDL it tries to be more concise and readable, while also adding new features like generic synchronizations and type inheritance.

This repository contains a ghost-to-ddl command-line compiler, `ghostc`, and an [Eclipse](https://www.eclipse.org) plugin that can be used to ease development of planning domains and problems; the generated ddl files can then be given as input to a planner supported by the [KeeN Environment](https://ugilio.github.io/keen).

The ghost language was designed and implemented by Giulio Bernardi. Currently, the compiler and the Eclipse plugin should be considered *alpha* quality software: any API is subject to change, and the language itself might undergo some (hopefully minor) changes; this also means that bugs and other problems are expected (but if you find any of them, please [report them](https://github.com/ugilio/ghost/issues)). It is Open Source software released under the [Eclipse Public License](https://www.eclipse.org/legal/epl-v10.html).

