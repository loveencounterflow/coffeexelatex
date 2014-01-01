

# Coffee(Xe)(La)TeX

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

You may want to have a look at `examples/example-1/example-1.lgpl` to get a quick overview what exactly
happened behind the scenes (see [PerlTeX: Defining LaTeX macros using Perl](https://www.tug.org/TUGboat/tb25-2/tb81pakin.pdf)
for an overview of the process).

## Useful Links

http://www.ctan.org/tex-archive/macros/latex/contrib/perltex

http://ctan.space-pro.be/tex-archive/macros/latex/contrib/perltex/perltex.pdf

http://www.tug.org/TUGboat/tb28-3/tb90mertz.pdf

https://www.tug.org/TUGboat/tb25-2/tb81pakin.pdf

