---
title: Ghost
hide_sidebar: true
toc: false
permalink: index.html
---
<span class="sc">ghost</span> is a language for [Timeline-based Planning](https://ugilio.github.io/keen/intro), developed to replace [<span class="sc">ddl</span>](https://ugilio.github.io/keen/intro#the-ddl-language). With respect to <span class="sc">ddl</span> it tries to be more concise and readable, while also adding new features like generic synchronizations and type inheritance.

An implementation of the language exists in the form of a ghost-to-ddl command-line compiler, `ghostc`, and an [Eclipse](https://www.eclipse.org) plugin that can be used to ease development of planning domains and problems; the generated ddl files can then be given as input to a planner supported by the [KeeN Environment](https://ugilio.github.io/keen).

The <span class="sc">ghost</span> language was designed and implemented by Giulio Bernardi. Currently, the compiler and the Eclipse plugin should be considered *alpha* quality software: any API is subject to change, and the language itself might undergo some (hopefully minor) changes; this also means that bugs and other problems are expected (but if you find any of them, please [report them](https://github.com/ugilio/ghost/issues)). It is Open Source software released under the [Eclipse Public License](https://www.eclipse.org/legal/epl-v10.html).

### Documentation

* The complete language documentation is available in [The <span class="sc">ghost</span> Language Manual](/manual), which is accompanied by many examples.

* An introduction to Timeline-based Planning can be found [here](https://ugilio.github.io/keen/intro).

* There is also a [grammar of the <span class="sc">ghost</span> language in EBNF form](/ghostebnf).

### Getting Started

{% capture latest %}
{% include latestrelease.inc %}
{% endcapture %}

#### Eclipse Plugin
*TODO: add an update site*

#### Command-line compiler
**NOTE**: You don't need the command-line compiler if you plan to develop exclusively through Eclipse: the Eclipse plugin can compile sources on its own, without the need of an external compiler.

 * Download the latest release of the command-line compiler: choose the version for [Linux/macOS/other UNIX](https://github.com/ugilio/ghost/releases/download/v{{ latest }}/ghostc-{{ latest }}-bin.tar.bz2) or [Windows](https://github.com/ugilio/ghost/releases/download/v{{ latest }}/ghostc-{{ latest }}-bin.zip) according to your operating system. You can also download the source code from the [release page](https://github.com/ugilio/ghost/releases/latest).
 * Uncompress the content of the distribution in a directory of your choice.
 * Optional: ensure the `ghostc` executable can be found in your `PATH`:
   * **Linux/macOS**: you might add a symbolic link to ghostc in the `bin` directory in your home folder. For example, if ghostc has been uncompressed in the `ghostc` directory inside your home directory, this command will do: `ln -s ~/ghostc/bin/ghostc ~/bin/ghostc`
   * **Windows**: edit che `PATH` environment variable by appending the path to the `bin` directory (inside the folder where you unzipped the ghostc distribution) at the end of the string; be sure that the string you append is separated from the previous entries by a semicolon ';' character. For instructions about how to edit the `PATH` variable, see [here](https://www.java.com/en/download/help/path.xml).
 * You can now compile a ghost file with the command `ghostc filename.ghost`: the compiled ddl file will be generated in the same directory. To see other options, run `ghostc --help`. If you skipped the step above, you will have to specify the full path to the `ghostc` executable: for example, `~/ghostc/bin/ghostc filename.ghost` on Linux/macOS, or `C:\Path\Where\Ghostc\Is\Installed\bin\ghostc filename.ghost` on Windows.

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
