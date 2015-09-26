
data = require "./hero.js"
csrf = require "csrf-lite"
Joi = require "joi"
sendmail = require("./mail.js")
jsonfile = require('jsonfile')
work =
  examples: "#{__dirname}/data/work.json"
  codepens: "#{__dirname}/data/codepens.json"

examples = jsonfile.readFileSync(work.examples)
codepens = jsonfile.readFileSync(work.codepens)

###
    Routes
###

scheme = Joi.object().keys
  'name': Joi.string().min(3).max(64).required()
  'email': Joi.string().email().required()
  'message': Joi.string().min(3).max(64).required()
  'x-csrf-token': Joi.string()


module.exports = (server) ->
  # static asset routes

  ## favicon
  server.route
      method: 'GET'
      path:'/favicon.ico'
      handler: (request, reply) ->
        reply.file("./favicon.ico");

  ## images
  server.route
      method: 'GET'
      path: '/images/{file*}'
      handler:
        directory:
          path: 'public/images',
          listing: true

  ## css
  server.route
      method: 'GET'
      path: '/css/{file*}'
      handler:
        directory:
          path: 'public/css'
          listing: true

  ## scripts
  server.route
    method: 'GET'
    path: '/scripts/{file*}'
    handler:
      directory:
        path: 'public/scripts'
        listing: true

  ## generic file
  server.route
      method: 'GET'
      path: '/{file*}'
      handler:
        directory:
          path: 'public'
          listing: true

  # custom routes
  ## home
  server.route
    method: 'GET'
    path:'/'
    handler: (req, reply) ->
      reply.view('index', {data})

  server.state "_token", {
    ttl: 60*60*1000
    isSecure: false
    isHttpOnly: true
    encoding: 'base64json'
  }

  server.route
    method: 'GET'
    path: '/contact'
    config:
      state:
        parse: true
    handler: (req, reply) ->
      token = req.state._token
      unless token
        token = csrf()
      reply.view "contact",
        token: csrf.html(token),
        postdata: {}
      .state("_token", token)

  server.route
    method: 'POST'
    path: '/contact'
    config:
      state:
        parse: true
    handler: (req, reply) ->
      # session token
      token = req.state._token
      postdata = Joi.validate(req.payload, scheme)

      if postdata.error
        return reply.view("contact", {
          token: csrf.html(token),
          postdata: postdata.value,
          errors: postdata.error
        })

      # validate our csrf token
      if csrf.validate(postdata.value, token) is false
        # dont let csrf's know that their attempt was found
        reply.view("contact", {messageSent: true, postdata: postdata})
      else
        sendmail postdata.value, (error, info) ->
          if error
            console.log "An error occurred when sending mail.", error
            reply.view("error", {message: "An error occurred when sending mail."})
          else
            reply.view("contact", {messageSent: true})


  server.route
    method: 'GET'
    path: "/about"
    handler: (req, reply) ->
      reply.view("about")


  server.route
    method: 'GET'
    path: "/work"
    handler: (req, reply) ->
      # examples and codepens are used to generate the content

      reply.view("work", {examples, codepens})



  return server
