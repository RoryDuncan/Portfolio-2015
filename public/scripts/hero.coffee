


shuffle = (a) ->
    i = a.length
    while --i > 0
        j = ~~(Math.random() * (i + 1))
        t = a[j]
        a[j] = a[i]
        a[i] = t
    a

# renders the images as a 3x3 grid on the canvas
renderImagesAs3by3 = (canvas, images) ->
  shuffle(images)
  canvas.clear("#fcfcfc")
  padding = 20 # padding to help center
  width = height = 150
  y = 0
  for image, i in images
    do (image, i) ->
      x = (i % 3) * width
      if i % 3 is 0 and i isnt 1 and i isnt 0
        y += 1
      canvas.drawImage(image, padding + x, padding + y * height, width, height)
run = () ->
  images = []
  loaded = 0
  data = window.herodata
  el = document.getElementById("hero")
  # test if canvas is visible, if it isn't, dont continue

  if window.getComputedStyle(el).getPropertyValue("display") is "none"
    return

  canvas = new CodePenCanvas({el, maximize: false})
  canvas.canvas.width = canvas.width = canvas.height = canvas.canvas.height = 500

  complete = () ->
    mouse = {
      x: canvas.width / 2,
      y: canvas.height / 2
    }
    hovers = 1
    changes = 10
    action = () ->
      renderImagesAs3by3(canvas, images)
      changes -= 1
      hovers += 2
    limited = canvas.throttle action, 120
    canvas.render () ->
      limited() if changes > 0



    canvas.start()
    limited()
    canvas.canvas.addEventListener  "mouseover", () ->
      changes =  2 + ~~(Math.random()*30)



    return

  loadImage = () ->
    loaded++
    complete() if loaded is data.images.length
    return

  for image in data.images
    do (image) ->
      img = new Image()
      img.onload = loadImage
      img.src = data.path + image
      images.push img

document.onreadystatechange = () ->
  run() if document.readyState is "complete"
