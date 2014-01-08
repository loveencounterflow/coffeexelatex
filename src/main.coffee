




############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
#...........................................................................................................
BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'scratch'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
_echo                     = TRM.echo.bind TRM
#...........................................................................................................
eventually                = process.nextTick
coffee                    = require 'coffee-script'
Line_by_line              = require 'line-by-line'

#-----------------------------------------------------------------------------------------------------------
# Object to represent entries in (a copy of) the `*.aux` file:
@aux = {}

#-----------------------------------------------------------------------------------------------------------
@main = ->
  # try
  #   xxx
  #   @_main()
  # catch error
  #   debug "there was an unhandled exception"
  #   debug()
  #   debug error[ 'message' ]
  #   debug error[ 'stack' ]
  @_main()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  ### The `main` routine collects the command name and command parameters from the environment
  ###
  info "©45 argv: #{rpr process.argv}"
  texroute    = process.argv[ 2 ]
  command     = process.argv[ 3 ]
  parameter   = process.argv[ 4 ]
  ### TAINT we naïvely split on comma, which is not robust in case e.g. string or list literals contain
  that character. Instead, we should be doing parsing (eg. using JSON? CoffeeScript expressions /
  signatures?) ###
  parameters  = parameter.split ','
  method_name = command.replace /-/g, '_'
  # info "©44 texroute: #{rpr texroute}"
  # info "©46 command: #{rpr command}, parameter: #{rpr parameter}"
  #.........................................................................................................
  unless @[ method_name ]?
    message = "Unknown command: #{rpr command}"
    warn  message
    debug message
    return null
  #.........................................................................................................
  @read_aux texroute, ( error ) =>
    throw error if error?
    warn @aux
    echo R if ( R = @[ method_name ] parameters... )?
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@read_aux = ( texroute, handler ) ->
  last_idx  = texroute.length - 1 - ( njs_path.extname texroute ).length
  auxroute  = texroute[ 0 .. last_idx ].concat '.auxcopy'
  # warn "#{auxroute} has #{( njs_fs.statSync auxroute ).size} bytes"
  unless njs_fs.existsSync auxroute
    warn "unable to locate #{auxroute}; ignoring"
    eventually => handler null
    return null
  #.........................................................................................................
  @aux[ 'auxroute'  ] = auxroute
  @aux[ 'labels'    ] = labels = {}
  #.........................................................................................................
  @_lines_of auxroute, ( error, line, line_nr ) =>
    return handler error if error?
    if line is null
      postprocess()
      return handler null
    #.......................................................................................................
    ### De-escaping characters: ###
    line = line.replace @read_aux.protectchar_matcher, ( $0, $1 ) =>
      return String.fromCharCode parseInt $1, 16
    #.......................................................................................................
    ### Compiling and evaluating CoffeeScript: ###
    if ( match = line.match @read_aux.coffeescript_matcher )?
      try
        source  = coffee.compile match[ 1 ], 'bare': yes, 'filename': auxroute
        x       = eval source
      catch error
        warn "unable to parse line #{line_nr} of #{auxroute}:"
        warn line
        warn rpr error
        return null
      switch type = TYPES.type_of x
        when 'pod'
          @aux[ name ] = value for name, value of x
        else
          warn "ignoring value of type #{type} on line #{line_nr} of #{auxroute}:\n#{rpr line}"
      return null
    #.......................................................................................................
    ### Parsing labels and references: ###
    if ( match = line.match @read_aux.newlabel_matcher )?
      [ ignore, label, ref, pageref, title, unknown, unknown, ] = match
      labels[ label ] =
        name:           label
        ref:            parseInt ref,     10
        pageref:        parseInt pageref, 10
        title:          title
      return null

  #---------------------------------------------------------------------------------------------------------
  postprocess = =>
    ### Postprocessing of the data delivered by the `\auxgeo` command.

    All resulting lemgths are in millimeters. `firstlinev` is the distance between the
    top of the paper and the top of the first line of text. Similarly, the implicit 1 inch distance in
    `\voffset` and `\hoffset` is being made explicit so that the reference point is shifted to the paper's
    top left corner.

    See http://www.ctex.org/documents/packages/layout/layman.pdf p9 and
    http://en.wikibooks.org/wiki/LaTeX/Page_Layout ###
    one_inch = 4736286
    if ( g = @aux[ 'geometry' ] )?
      for name, value of g
        value += one_inch if name is 'voffset'
        value += one_inch if name is 'hoffset'
        g[ name ] = value / 27597261 * 148.5
      g[ 'firstlinev' ] = g[ 'voffset' ] + g[ 'topmargin' ] + g[ 'headsep' ] + g[ 'headheight' ]
  #.........................................................................................................
  return null

#...........................................................................................................
### matcher for those uber-verbosely: `\protect \char "007B\relax` escaped characters: ###
@read_aux.protectchar_matcher = ///
  \\protect \s+ \\char \s+ "( [ 0-9 A-F ]+ )\\relax \s?
  ///g

#...........................................................................................................
### matcher for CoffeeScript: ###
@read_aux.coffeescript_matcher = ///
  ^ % \s+ coffee\s+ ( .+ ) $
  ///

### \newlabel{otherlabel}{{2}{3}} ###
### \newlabel{otherlabel}{{2}{3}{References}{section.2}{}} ###
### TAINT not sure whether this RegEx is backtracking-safe as per
  http://www.regular-expressions.info/catastrophic.html ###
@read_aux.newlabel_matcher = ///
  ^ \\newlabel \{ ( [^{}]+ ) \}
  \{
    \{ ( [0-9]* ) \}
    \{ ( [0-9]* ) \}
    (?:
      \{ ( [^{}]* ) \}
      \{ ( [^{}]* ) \}
      \{ ( [^{}]* ) \}
      )?
    \} $ ///

#-----------------------------------------------------------------------------------------------------------
@_lines_of = ( route, handler ) ->
  line_nr = 0
  #.........................................................................................................
  line_reader = new Line_by_line route
  line_reader.on 'error', ( error ) => handler error
  line_reader.on 'end',             => handler null, null
  #.........................................................................................................
  line_reader.on 'line',  ( line  ) =>
    line_nr += 1
    handler null, line, line_nr
  #.........................................................................................................
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@debug = ( message ) ->
  return echo() unless message?
  echo "\\textbf{\\textcolor{red}{#{@escape message.replace /\n+/g, '\\par\\n\\n' }}}"

#-----------------------------------------------------------------------------------------------------------
@echo = ( P... ) ->
  whisper P...
  return _echo P...

#-----------------------------------------------------------------------------------------------------------
debug = @debug.bind @
echo  = @echo.bind @


#===========================================================================================================
# SAMPLE COMMANDS
#-----------------------------------------------------------------------------------------------------------
@helo = ( name ) ->
  return "{Hello, \\textcolor{blue}{#{@escape name}}!}"

#-----------------------------------------------------------------------------------------------------------
@page_and_line_nr = ( page_nr, line_nr ) ->
  page_nr     = parseInt page_nr, 10
  line_nr     = parseInt line_nr, 10
  return """
    Helo from NodeJS.
    This paragraph appears on page #{page_nr}, column ..., line #{line_nr}."""

#-----------------------------------------------------------------------------------------------------------
@show_geometry = ->
  unless ( g = @aux[ 'geometry' ] )?
    debug """unable to retrieve geometry info from #{@aux[ 'auxroute' ]};"""
      # you may want to consider using `\\auxgeo` in your TeX source."""
    return null
  #.........................................................................................................
  R     = []
  names = ( name for name of g ).sort()
  #.........................................................................................................
  for name in names
    value = g[ name ]
    value = if value? then ( ( value.toFixed 2 ).concat 'mm' ) else './.'
    R.push "#{name}: #{value}"
  #.........................................................................................................
  return "Geometry:\\par\n".concat R.join '\\par\n'

#-----------------------------------------------------------------------------------------------------------
@show_special_chrs = ->
  chr_by_names =
    'opening brace':    '{'
    'closing brace':    '}'
    'Dollar sign':      '$'
    'ampersand':        '&'
    'hash':             '#'
    'caret':            '^'
    'underscore':       '_'
    'wave':             '~'
    'percent sign':     '%'
  #.........................................................................................................
  R = []
  for name, chr of chr_by_names
    R.push "#{name}: #{@escape chr}"
  #.........................................................................................................
  return "Special characters:\\par\n".concat R.join '\\par\n'


#===========================================================================================================
# SERIALIZATION
#-----------------------------------------------------------------------------------------------------------
@_escape_replacements = [
  [ ///  \\  ///g,  '\\textbackslash{}',    ]
  [ ///  \{  ///g,  '\\{',                  ]
  [ ///  \}  ///g,  '\\}',                  ]
  [ ///  &   ///g,  '\\&',                  ]
  [ ///  \$  ///g,  '\\$',                  ]
  [ ///  \#  ///g,  '\\#',                  ]
  [ ///  %   ///g,  '\\%',                  ]
  [ ///  _   ///g,  '\\_',                  ]
  [ ///  \^  ///g,  '\\textasciicircum{}',  ]
  [ ///  ~   ///g,  '\\textasciitilde{}',   ]
  # '`'   # these two are very hard to catch when TeX's character handling is switched on
  # "'"   #
  ]

#-----------------------------------------------------------------------------------------------------------
@escape = ( text ) ->
  R = text
  for [ matcher, replacement, ] in @_escape_replacements
    R = R.replace matcher, replacement
  return R

############################################################################################################
@main()
# @read_aux '/Volumes/Storage/cnd/node_modules/coffeexelatex/examples/example-1/example-1.aux', ( error, aux ) ->
#   throw error if error?
#   info '©34d', aux











