




############################################################################################################
# ERROR                     = require 'coffeenode-stacktrace'
njs_util                  = require 'util'
# njs_path                  = require 'path'
njs_fs                    = require 'fs'
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
# debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
# rainbow                   = TRM.rainbow.bind TRM
# suspend                   = require 'coffeenode-suspend'
# step                      = suspend.step
# after                     = suspend.after
# eventually                = suspend.eventually
# immediately               = suspend.immediately
# every                     = suspend.every
# TEXT                      = require 'coffeenode-text'

#-----------------------------------------------------------------------------------------------------------
@main = ->
  ### The `main` routine collects the command name and command parameters from the environment
  ###
  command     = process.argv[ 2 ]
  parameter   = process.argv[ 3 ]
  ### TAINT we naïvely split on comma, which is not robust in case e.g. string or list literals contain
  that character. Instead, we should be doing parsing (eg. using JSON? CoffeeScript expressions /
  signatures?) ###
  parameters  = parameter.split ','
  method_name = command.replace /-/g, '_'
  # debug "command: #{rpr command}, parameter: #{rpr parameter}"
  #.........................................................................................................
  unless @[ method_name ]?
    message = "!!! Unknown command: #{rpr command} !!!"
    log   message
    echo  message
    return null
  #.........................................................................................................
  echo @[ method_name ] parameters...
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@debug = ( message ) ->
  echo "\\textbf{\\textcolor{red}{#{@escape message}}}"
  echo message

#-----------------------------------------------------------------------------------------------------------
debug = @debug.bind @

#-----------------------------------------------------------------------------------------------------------
@page_and_line_nr = ( page_nr, line_nr ) ->
  page_nr     = parseInt page_nr, 10
  line_nr     = parseInt line_nr, 10
  return """
    helo from NodeJS."
    this paragraph appears on page #{page_nr}, column ..., line #{line_nr}."""


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
