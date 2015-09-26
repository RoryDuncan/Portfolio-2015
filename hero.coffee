
fs = require "fs"
path = require "path"


# gets all the files in a folder and lists their files,
# then puts inside a json file.


filename = "glitch.json"
pathInBrowser = "/images/glitch/"
glitchPath = "/public" + pathInBrowser
folder = path.join __dirname, glitchPath


generateConfig = () ->
  files = fs.readdirSync folder

  data = {
    'path': pathInBrowser,
    'images': files
  }
  data = JSON.stringify(data)
  fs.writeFileSync("public/#{filename}", data)
  return data

module.exports = generateConfig()
