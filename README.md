

# Coffee(Xe)(La)TeX

## What is it? And Why?

Everyone who has worked with LaTeX knows how hard it can often be to get seemingly simple things done in
this Turing-complete markup language. Let's face it, (La)TeX has many problems; the [complectedness](http://www.infoq.com/presentations/Simple-Made-Easy)
of its inner workings and the extremely uneven syntax of its commands put a heavy burden on the average
user. The funny thing is that while TeX is all about computational text processing, doing some math and some
string processing are *really hard* to get right, or sometimes done at all, in this environment. Not to
mention that TeX has no notion of higher-order data types, such as lists.

Often one wishes one could just do a simple calculation or build a typesetting object from available data
*outside* of all that makes LaTeX so difficult to get right. Turns out: you can already do that.

Few people seem to have realized that **there is a widely distributed TeX engine that allows execution of
arbitrary code outside the TeX VM that provides a two-way communication from TeX to the external program
and back from that external program to TeX**. This thing is called [PerlTeX](http://www.ctan.org/tex-archive/macros/latex/contrib/perltex).

In short, here are a few great things about PerlTeX:

* It's *not* a custom-patched TeX version, but just a Perl script and a LaTeX `.sty` file*.

  > \*) in other words: TeX can already execute external programs *by itself*. The important added value
  > of PerlTeX is that it provides a reasonably safe and efficient framework to ensure communication between
  > multiple processes and that it hides the (ugly) details from the casual user.

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

## Future Development

If CoffeeXeLaTeX turns out to be a useful tool, i can presently see the following routes for development:

* Using a Perl shell-escape command to start `node` all over for each single JS/CS macro is doubly
  wasteful—first, a `perl` process is started which in turn starts a `node` subprocess. Depending on
  specific use, this can mean that two processes (none of them exactly lightweight) are initiated hundreds
  or thousands of times for a single document. This may be fixed in a number of ways:

  * Firstly, we could try and remove the Perl dependency, and call `node` in exactly the way that `perl`
    is called now. Not sure how to do that at this point in time.

  * Secondly, we could opt for a client / server model and make it so that instead of starting a (heavy)
    process for each JS/CS macro call, a (HTTP?) connection to a long-running NodeJS server is established.
    This is also attractive as it would simplify state keeping—as it stands, each call to a given macro
    starts with a clean slate (though one could imagine storing results from past calls in a file or a
    database).

  Both of the above options are only worth implementing when it has been shown that substantial benefits
  in terms of performance, easy of use, and capabilities can be gained—something that is only meaningful
  after experience with real-world use cases has been gained.

* The one big incentive for using a 3rd-party language in tandem with LaTeX is to make things easy (or
  at least achievable) that are difficult (or impossible) using only LaTeX.

  Regrettably, our efforts are still limited to what can be communicated 'over the wire' between the LaTeX
  process and the macro process; we do not have direct access to (La)TeX internals as such, but must package
  every pertinent facet of the ongoing typesetting process as a textual argument for a macro.

  Imagine you had to interact with your HTML page in this way—imagine JavaScript in the browser was
  stateless and blissfully unaware of the DOM and CSS, imagine HTML was Turing-complete-but-hard-to-use
  as is the case with TeX. Your capabilities-improved web application page would be littered with ugly
  `<if condition='...'>...</if>` tags and circumlocutorily reified calls to JS. This is the state of affairs
  of PerlTeX / CoffeeXeLaTeX, and it is definitely a programming model begging to be improved.



## Related Work

from http://get-software.net/macros/latex/contrib/pythontex

% \begin{itemize}
% \item \href{http://www.ctan.org/tex-archive/macros/latex/contrib/perltex/}{Perl\TeX} allows the bodies of \LaTeX\ macros to be written in Perl.
% \item \href{http://www.ctan.org/tex-archive/macros/latex/contrib/sagetex/}{Sage\TeX} allows code for the Sage mathematics software to be executed from within a \LaTeX\ document.
% \item Martin R.\ Ehmsen's \href{http://www.ctan.org/pkg/python}{|python.sty|} provides a very basic method of executing Python code from within a \LaTeX\ document.
% \item \href{http://elec.otago.ac.nz/w/index.php/SympyTeX}{Sympy\TeX} allows more sophisticated Python execution, and is largely based on a subset of Sage\TeX.
% \item \href{http://www.luatex.org/}{Lua\TeX} extends the pdf\TeX\ engine to provide Lua as an embedded scripting language, and as a result yields tight, low-level Lua integration.
% \end{itemize}


## Useful Links

http://www.ctan.org/tex-archive/macros/latex/contrib/perltex

http://ctan.space-pro.be/tex-archive/macros/latex/contrib/perltex/perltex.pdf

http://www.tug.org/TUGboat/tb28-3/tb90mertz.pdf

https://www.tug.org/TUGboat/tb25-2/tb81pakin.pdf

