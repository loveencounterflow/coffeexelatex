




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
debug                     = TRM.get_logger 'debug',     badge
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
@page_and_line_nr = ( page_nr, line_nr ) ->
  page_nr     = parseInt page_nr, 10
  line_nr     = parseInt line_nr, 10
  echo "helo from NodeJS."
  echo "this paragraph appears on page #{page_nr}, column ..., line #{line_nr}."

#-----------------------------------------------------------------------------------------------------------
@main = ->
  command     = process.argv[ 2 ]
  parameter   = process.argv[ 3 ]
  parameters  = parameter.split ','
  method_name = command.replace /-/g, '_'
  echo "!!! DEBUG command: #{rpr command}, parameter: #{rpr parameter}. !!!"
  #.........................................................................................................
  unless @[ method_name ]?
    message = "!!! Unknown command: #{rpr command} !!!"
    log   message
    echo  message
    return null
  #.........................................................................................................
  return @[ method_name ] parameters...


############################################################################################################
@main()
