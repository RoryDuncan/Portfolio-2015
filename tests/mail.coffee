nodemailer = require('nodemailer')

transporter = nodemailer.createTransport
  service: 'gmail'
  auth:
    user: process.env.gmailAccount
    pass: process.env.gmailPassword


options =
  from:     "Rory Duncan <robust.rory@gmail.com>"
  to:       "Test <robust.rory@gmail.com>"
  subject:  "meow.coffee Contact Form Submission"
  text:     "This is a test message"

transporter.sendMail options, (error, info) ->
  if error
    console.log "ERROR"
    console.log error.code
    console.log error.response
  else
    console.log info.response
