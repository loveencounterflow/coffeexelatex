




############################################################################################################
# njs_util                  = require 'util'
njs_fs                    = require 'fs'
njs_path                  = require 'path'
njs_url                   = require 'url'
#...........................................................................................................
BAP                       = require 'coffeenode-bitsnpieces'
TYPES                     = require 'coffeenode-types'
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'CX/server'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
debug                     = TRM.get_logger 'debug',     badge
alert                     = TRM.get_logger 'alert',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
_echo                     = TRM.echo.bind TRM
#...........................................................................................................
eventually                = process.nextTick
# coffee                    = require 'coffee-script'
Line_by_line              = require 'line-by-line'
#...........................................................................................................
express                   = require 'express'
CX                        = require './main'

# #...........................................................................................................
# ### https://github.com/goodeggs/teacup ###
# teacup                    = require 'teacup'
# # #...........................................................................................................
# templates                 = require './templates'
# express                   = require 'express'
# flash                     = require 'express-flash'
#...........................................................................................................
# app_info                  = OPTIONS.get_app_info()
# ### Name used to store info on the `request` object: ###
# app_key                   = app_info[ 'name' ]
#...........................................................................................................
# A1                        = require './main'
# view                      = A1.get_view_for           templates
# restrict_view             = A1.get_restrict_view_for  templates
#...........................................................................................................
milliseconds  =    1
seconds       = 1000 * milliseconds
minutes       =   60 * seconds
hours         =   60 * minutes
days          =   24 * hours
weeks         =    7 * days
months        =   30 * days
years         =  365 * days

#-----------------------------------------------------------------------------------------------------------
server_options =
  'host':         '127.0.0.1'
  'port':         8910

#-----------------------------------------------------------------------------------------------------------
express_options =
  'static-routes': [
    'public'
    'common' ]
  'logger':
    # 'format': 'short'     # ':remote-addr - :method :url HTTP/:http-version :status :res[content-length] - :response-time ms'
    # 'format': 'tiny'      # ':method :url :status :res[content-length] - :response-time ms'
    # 'format': 'default'   # ':remote-addr - - [:date] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent"'
    # 'format': 'mingkwai'  # own format
    'format': 'dev'       # concise output colored by response status for development use



#-----------------------------------------------------------------------------------------------------------
@get_view = ->
  return ( name, options ) =>
    log 'retrieving view for', name
    #.......................................................................................................
    return ( request, response ) =>
      url         = request[ 'url' ]
      url         = ( njs_url.parse url, true )[ 'path' ]
      url         = decodeURIComponent url
      url         = url.replace /\++/g, ' '
      ### TAINT the NodeJS docs say: [the 'binary'] encoding method is deprecated and should be avoided
        [...] [it] will be removed in future versions of Node ###
      url         = new Buffer url, 'binary'
      url         = url.toString 'utf-8'
      crumbs      = ( url.replace /^\//, '' ).split '/'
      texroute    = crumbs[ 0 ]
      command     = crumbs[ 1 ]
      parameter   = crumbs[ 2 ] ? ''
      parameters  = parameter.split ','
      debug '©45f request for:', name
      debug '©45f url:        ', url
      debug '©45f crumbs:     ', crumbs
      debug '©45f texroute:   ', texroute
      debug '©45f command:    ', command
      debug '©45f parameter:  ', parameter
      unless CX[ command ]?
        message = "Unknown command: #{rpr command}"
        warn message
        R = CX._pen_debug message
      else
        R = ( CX[ command ] parameters... ) ? ''
      status  = 200
      headers =
        'Content-Type': 'text/plain'
      #.........................................................................................................
      response.writeHeader status, headers
      # response.write "an error has occurred"
      response.write R
      response.end()
      # #.....................................................................................................
      # content_done = ( content ) =>
      #   log TRM.blue 'content_done'
      #   throw new Error "content already finished; cannot call `done()` anymore" if content_already_done
      #   content_already_done = yes
      #   if content?
      #     return on_error content if TYPES.isa_jserror content
      #     page = templates.layout request, response, content, page_done
      #     if page?
      #       TYPES.validate_isa_text page
      #       page_done page
      #   else
      #     page_done()
      #   return null
      # #.....................................................................................................
      # page_done = ( page ) =>
      #   log TRM.blue 'page_done'
      #   throw new Error "page already finished; cannot call `done()` anymore" if page_already_done
      #   page_already_done = yes
      #   if ( request.listeners 'page ready' ).length > 0
      #     request[ 'A1' ][ 'page' ] = page
      #     request.emit 'page ready'
      #     page = request[ 'A1' ][ 'page' ]
      #   return on_error page if TYPES.isa_jserror page
      #   @HTTP.write_header request, response
      #   # debug '©22a', response.headerSent
      #   response.write page if page?
      #   response.end()
      #   return null
      # #.....................................................................................................
      # try
      #   content = templates[ name ] request, response, content_done
      #   # debug '©4e', rpr content
      #   if content?
      #     TYPES.validate_isa_text content
      #     content_done content
      # #.....................................................................................................
      # catch error
      #   on_error error
      # #.....................................................................................................
      # return null


#...........................................................................................................
app   = express()
view  = @get_view()

#-----------------------------------------------------------------------------------------------------------
# Middleware
#-----------------------------------------------------------------------------------------------------------
app.use express.json()
app.use express.urlencoded()
# app.use express.cookieParser 'ztfgGHzqk3'
# app.use express.session express_options[ 'session' ]
# app.use app.router # must be placed *after* cookieParser and session
#...........................................................................................................
# app.use A1.delay_headers()
# app.use A1.add_request_options()
# app.use A1.page_modifier()
# app.use A1.flash_notifications()
#...........................................................................................................
app.use express.logger express_options[ 'logger' ][ 'format' ]


#-----------------------------------------------------------------------------------------------------------
# Endpoints
#-----------------------------------------------------------------------------------------------------------
# Public Static Files
# do ->
#   for static_route in express_options[ 'static-routes' ]
#     static_route  = '/'.concat njs_path.basename static_route
#     fs_route      = njs_path.join app_info[ 'home' ], static_route
#     # app.get url_route, express.static static_route
#     app.use static_route, express.static fs_route
#     info "static route:", ( TRM.gold static_route ), ( TRM.grey '->', fs_route )
# #...........................................................................................................
# app.use A1.show_sid express_options[ 'session' ][ 'secret' ]
# app.all '*', A1.show_debug_info()

#-----------------------------------------------------------------------------------------------------------
# Dynamic Endpoints
#...........................................................................................................
# General Locations
# app.get   '/',            view 'homepage'
app.get   '*',            view 'all'
# #...........................................................................................................
# # Boilerplate Locations
# app.get   '/contact',     view 'contact'
# app.get   '/imprint',     view 'imprint'
# app.get   '/privacy',     view 'privacy'
# #...........................................................................................................
# # Login / Logout Locations
# app.get   '/welcome',     view 'welcome',     'remember-location': no
# app.get   '/goodbye',     view 'goodbye',     'remember-location': no
# app.get   '/login',       view 'login_get',   'remember-location': no
# app.post  '/login',       view 'login_post',  'remember-location': no
# app.post  '/signup',      view 'signup_post', 'remember-location': no
# app.all   '/logout',      view 'logout',      'remember-location': no
# #...........................................................................................................
# # Restricted Locations
# app.get   '/restricted',  restrict_view 'user', 'restricted'
#...........................................................................................................
# Fallback View
app.use view 'not_found'


#===========================================================================================================
# SERVING
#-----------------------------------------------------------------------------------------------------------
app.listen server_options[ 'port' ], ( error ) ->
  throw error if error?
  #.........................................................................................................
  # for static_route in static_routes
  #   info "static route: #{static_route}"
  log TRM.green "listening to #{server_options[ 'host' ]}:#{server_options[ 'port' ]}"


############################################################################################################
# @serve()
