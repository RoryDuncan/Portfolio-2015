
Hapi = require 'hapi'
setupRoutes = require("./routes.js")



server = new Hapi.Server()
server.connection({port: process.env.PORT or 5000})

server.views
  engines:
    jade: require('jade')
  relativeTo: __dirname
  path: './views'
  layoutPath: './views/shared'
  isCached: false

setupRoutes(server)

server.start () ->
  console.log "\nServer running on #{server.info.uri}\n"
