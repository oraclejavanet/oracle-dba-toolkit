================================================================================
                                    Doxygen
================================================================================

--------------------------------------------------------------------------------
Table of Contents
--------------------------------------------------------------------------------

    [*] Overview
    [*] Quick Install Guide
    [*] Configure Doxygen for "Oracle DBA Toolkit"
    [*] Configure Doxygen
    [*] Generate Documentation
    [*] Documenting the Sources
    [*] References

--------------------------------------------------------------------------------
Overview
--------------------------------------------------------------------------------

The C source code included in the "Oracle DBA Toolkit" leverages Doxygen for
code documentation.

This note explains how to download, install, and configure the latest version
of Doxygen for Linux and Oracle Solaris.

--------------------------------------------------------------------------------
Quick Install Guide
--------------------------------------------------------------------------------

This section explains how to build and install the latest version of Doxygen
from source. The source code is hosted on GitHub. The Git repository provides
the latest version of Doxygen.

-------------------
Check prerequisites
-------------------

    errors_found=0
    for c in g++ python3 flex bison git
    do
        if ! command -v $c &> /dev/null
        then
            echo
            echo "Error: The \"$c\" command could not be found."
            errors_found=1
        fi
        echo "Found the \"$c\" command."
    done
    if [[ ${errors_found=1} -eq 1 ]]; then
        echo "Failed prerequisites."
    else
        echo "Passed prerequisites."
    fi

-----
Linux
-----
    
    $ cd ~/repos
    $ git clone git@github.com:doxygen/doxygen.git
    $ cd doxygen
    $ mkdir build && cd $_
    $ cmake -G "Unix Makefiles" ..
    $ make
    $ sudo make install

Binaries are installed into the directory /usr/local/bin, man pages in
/usr/local/man/man1 and documentation in /usr/local/doc/doxygen.

    $ which doxygen
    /usr/local/bin/doxygen

----------------------
Oracle Solaris (SunOS)
----------------------

    Instal requisite utilities (from the OpenCSW project)
    # pkgadd -d http://get.opencsw.org/now
    # /opt/csw/bin/pkgutil -U
    # /opt/csw/bin/pkgutil -y -i flex
    # /opt/csw/bin/pkgutil -y -i bison
    # /opt/csw/bin/pkgutil -y -i cmake

    $ cd ~/repos
    $ git clone git@github.com:doxygen/doxygen.git
    $ cd doxygen
    $ mkdir build && cd $_
    $ cmake -G "Unix Makefiles" ..
    $ make
    $ sudo make install

--------------------------------------------------------------------------------
Configure Doxygen for "Oracle DBA Toolkit"
--------------------------------------------------------------------------------

This section explains how to configure Doxygen for use with the sample C program
in the "Oracle DBA Toolkit" used to demonstrate the Oracle External Procedures
(EXTPROC) feature.

The C source code can be found in the directory:

    'oracle-dba-toolkit/extproc/example/'

Use the following command to generate a Doxygen template configuration file for
the project:

    $ cd oracle-dba-toolkit/extproc/example
    $ doxygen -g

Create a new directory to store the generated documentation from Doxygen:

    $ mkdir -p project-docs

Finally, open the generated Doxyfile and modify the following settings for the
project:

    PROJECT_NAME           = "Oracle External Procedures Example"
    OUTPUT_DIRECTORY       = project-docs
    GENERATE_HTML          = YES
    HTML_OUTPUT            = html
    HTML_FILE_EXTENSION    = .html
    OBFUSCATE_EMAILS       = YES
    HTML_FORMULA_FORMAT    = png
    GENERATE_LATEX         = YES
    LATEX_OUTPUT           = latex
    USE_MATHJAX            = YES

The next section (Configure Doxygen) provides a more detailed explanation of the
key settings and options available in a Doxyfile.

--------------------------------------------------------------------------------
Configure Doxygen
--------------------------------------------------------------------------------

After installing Doxygen and adding Doxygen comments to your source code,
the next step is to create a Doxyfile configuration file for your project.

Doxygen uses a configuration file to determine all of its settings
(i.e., Doxyfile). Each project should get its own configuration file.
A project can consist of a single source file, but can also be an entire source
tree that is recursively scanned.

Use the following command to generate a Doxygen template configuration file:

    $ cd <your project directory>
    $ doxygen -g

    Configuration file 'Doxyfile' created.

    Now edit the configuration file and enter

    doxygen

    to generate the documentation for your project

Open the generated Doxyfile in a text editor and modify the settings according
to your preferences. Pay attention to settings like INPUT, which specifies the
source code directory, and OUTPUT_DIRECTORY, which determines where the
documentation will be generated.

The configuration file has a format that is similar to that of a (simple)
Makefile. It consists of a number of assignments (tags) of the form:

    TAGNAME = VALUE or
    TAGNAME = VALUE1 VALUE2 ...

You can probably leave the values of most tags in a generated template
configuration file to their default value. See section [Configuration] for more
details about the configuration file.

    https://www.doxygen.nl/manual/config.html

If you do not wish to edit the configuration file with a text editor, you should 
have a look at doxywizard (not covered in this note), which is a GUI front-end
that can create, read and write doxygen configuration files, and allows setting
configuration options by entering them via dialogs.

    https://www.doxygen.nl/manual/doxywizard_usage.html

For a small project consisting of a few C and/or C++ source and header files,
you can leave INPUT tag empty and doxygen will search for sources in the current
directory.

    https://www.doxygen.nl/manual/config.html#cfg_input

If you have a larger project consisting of a source directory or tree, you
should assign the root directory or directories to the INPUT tag, and add one or
more file patterns to the FILE_PATTERNS tag (for example, *.cpp *.h). Only files
that match one of the patterns will be parsed (if the patterns are omitted a
list of typical patterns is used for the types of files doxygen supports).
For recursive parsing of a source tree you must set the RECURSIVE tag to YES.
To further fine-tune the list of files that is parsed the EXCLUDE and
EXCLUDE_PATTERNS tags can be used. To omit all test directories from a source
tree for instance, one could use:

    EXCLUDE_PATTERNS = */test/*

    See:
        https://www.doxygen.nl/manual/config.html#cfg_input
        https://www.doxygen.nl/manual/config.html#cfg_file_patterns
        https://www.doxygen.nl/manual/config.html#cfg_recursive
        https://www.doxygen.nl/manual/config.html#cfg_exclude
        https://www.doxygen.nl/manual/config.html#cfg_exclude_patterns

Doxygen looks at the file's extension to determine how to parse a file, using
the following table:

Extension   Language    Extension   Language    Extension   Language
----------- ----------- ----------- ----------- ----------- --------------------
.dox        C / C++     .HH         C / C++     .py         Python
.doc        C / C++     .hxx        C / C++     .pyw        Python
.c          C / C++     .hpp        C / C++     .f          Fortran
.cc         C / C++     .h++        C / C++     .for        Fortran
.cxx        C / C++     .mm         C / C++     .f90        Fortran
.cpp        C / C++     .txt        C / C++     .f95        Fortran
.c++        C / C++     .idl        IDL         .f03        Fortran
.cppm       C / C++     .ddl        IDL         .f08        Fortran
.ccm        C / C++     .odl        IDL         .f18        Fortran
.cxxm       C / C++     .java       Java        .vhd        VHDL
.c++m       C / C++     .cs         C#          .vhdl       VHDL
.ii         C / C++     .d          D           .ucf        VHDL
.ixx        C / C++     .php        PHP         .qsf        VHDL
.ipp        C / C++     .php4       PHP         .l          Lex
.i++        C / C++     .php5       PHP         .md         Markdown
.inl        C / C++     .inc        PHP         .markdown   Markdown
.h          C / C++     .phtml      PHP         .ice        Slice
.H          C / C++     .m          Objective-C
.hh         C / C++     .M          Objective-C

Please note that the above list might contain more items than that by default
set in the FILE_PATTERNS.

    https://www.doxygen.nl/manual/config.html#cfg_file_patterns

Any extension that is not parsed can be set by adding it to FILE_PATTERNS
nd when the appropriate EXTENSION_MAPPING is set.

    https://www.doxygen.nl/manual/config.html#cfg_extension_mapping

If you start using doxygen for an existing project (thus without any
documentation that doxygen is aware of), you can still get an idea of what the
structure is and how the documented result would look like. To do so, you must
set the EXTRACT_ALL tag in the configuration file to YES. Then, doxygen will
pretend everything in your sources is documented. Please note that as a
consequence warnings about undocumented members will not be generated as long as
EXTRACT_ALL is set to YES.

    https://www.doxygen.nl/manual/config.html#cfg_extract_all

To analyze an existing piece of software it is useful to cross-reference a
(documented) entity with its definition in the source files. Doxygen will
generate such cross-references if you set the SOURCE_BROWSER tag to YES.
It can also include the sources directly into the documentation by setting
INLINE_SOURCES to YES (this can be handy for code reviews for instance).

    https://www.doxygen.nl/manual/config.html#cfg_source_browser
    https://www.doxygen.nl/manual/config.html#cfg_inline_sources

--------------------------------------------------------------------------------
Generate Documentation
--------------------------------------------------------------------------------

Run Doxygen with the configuration file:

    $ cd <your project directory>
    $ doxygen Doxyfile

This will generate documentation in the specified output directory.

--------------------------------------------------------------------------------
Documenting the Sources
--------------------------------------------------------------------------------

Tips:

    Documenting Files and Functions:

        * Use @file for file-level documentation.
        * Use @brief for a brief description of files and functions.
        * Provide detailed descriptions using regular comments following the
          @brief comment.

    Documenting Variables:

        * Use @param to document function parameters.
        * Use @return to document the return value of a function.

    Adding Sections:

        * Use @defgroup and @addtogroup to create groups of related functions or
          files.

    Special Commands:

        * Doxygen supports various special commands. Refer to the Doxygen
          documentation for a comprehensive list.

By following these steps and incorporating Doxygen comments into your C code,
you can easily generate and maintain comprehensive documentation for your
projects.

--------------------------------------------------------------------------------
References
--------------------------------------------------------------------------------

    [*] Doxygen (GitHub)
        https://github.com/doxygen

    [*] Doxygen (GitHub Repository)
        https://github.com/doxygen/doxygen

    [*] Doxygen Installation Guide
        https://www.doxygen.nl/manual/install.html

    [*] Doxygen's Internal Documentation
        https://github.com/doxygen/doxygen-docs
