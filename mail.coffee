nodemailer = require('nodemailer')
jade = require('jade')
Path = require('path')
template = Path.join(__dirname, "/views/emailtemplate.jade")

transporter = nodemailer.createTransport
  service: 'gmail'
  auth:
    user: process.env.gmailAccount
    pass: process.env.gmailPassword

defaults =
  from:     "noreply@meow.coffee <#{process.env.gmailAccount}>"
  to:       "Rory Duncan <#{process.env.gmailAccount}>"
  subject:  "meow.coffee Contact Form Submission"
  html:     ""


module.exports = (postdata, callback) ->

  html = jade.renderFile(template, postdata)

  options =
    'from':     defaults.from
    'to':       defaults.to
    'subject':  defaults.subject
    'html':     html

  transporter.sendMail options, callback

  return

