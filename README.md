

# Coffee(Xe)(La)TeX

## What is it? And Why?

Everyone who has worked with LaTeX knows how hard it can often be to get seemingly simple things done in
this Turing-complete markup language. Let's face it, (La)TeX has many problems; the [complectedness](http://www.infoq.com/presentations/Simple-Made-Easy)
of its inner workings and the extremely uneven syntax of its commands put a heavy burden on the average
user. The funny thing is that while TeX is all about computational text processing, text processing and
computations are *hard* to get right, or sometimes done at all, in this environment.

Often one wishes one could just do a simple calculation or build a typesetting object from available data
*outside* of all that makes LaTeX so difficult to get right. Turns out: you can already do that.

Few people seem to have realized that **there is a widely distributed TeX engine that allows execution of
arbitrary code outside the TeX VM that provides a two-way communication from TeX to the external program
and back from that external program to TeX**. This thing is called [PerlTeX](http://www.ctan.org/tex-archive/macros/latex/contrib/perltex).

In short, here are a few great things about PerlTeX:

* It's *not* a custom-patched TeX version, but just a Perl script and a LaTeX `.sty` file.

* If you installed LiveTeX, chances are you already have the `perltex` executable on your path.

* PerlTeX has a command line switch that allows you to choose your (La)TeX engine (see below). For me that
  means *i can profit from the Unicode- and font-awareness of XeLaTeX* and *script my documents* at the same
  time.

* PerlTeX uses temporary files to communicate between the TeX and the script process; this makes the
  implementation fairly OS-agnostic.




## Installation

* put a symlink to your CoffeeXeLaTeX directory into a directory that is on LaTeX's search path; on OSX with
  LiveTeX, that could be `~/Library/texmf/tex/latex`.*

> *: obviously, you could put your CoffeeXeLaTeX installation directly there, but that strikes me as
> 'wrong'.

## Usage

For a quick test, do

    cd examples/example-1
    perltex --nosafe --latex=xelatex example-1.tex

from the command line; this should produce `examples/example-1/example-1.pdf` (along with some other files).

You may want to have a look at `examples/example-1/example-1.lgpl` to get an idea what exactly
happened behind the scenes (see [PerlTeX: Defining LaTeX macros using Perl](https://www.tug.org/TUGboat/tb25-2/tb81pakin.pdf)
for an overview of the process).



## Useful Links

http://www.ctan.org/tex-archive/macros/latex/contrib/perltex

http://ctan.space-pro.be/tex-archive/macros/latex/contrib/perltex/perltex.pdf

http://www.tug.org/TUGboat/tb28-3/tb90mertz.pdf

https://www.tug.org/TUGboat/tb25-2/tb81pakin.pdf

