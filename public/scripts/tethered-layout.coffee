




run = () ->
  fixed = document.querySelectorAll(".fixed")[0]
  prefixes = ["-moz-",  "", "-webkit-"] # empty string for a non-prefix
  scrollHandler = (e) ->
    scrolled = document.body.scrollTop
    for prefix in prefixes
      fixed.style["#{prefix}transform"] = "translateY(#{scrolled}px)"

  if window.innerWidth >= 540
    window.addEventListener "scroll", scrollHandler

delayed = () ->
  # loads all delayed src iframes (that have data-src attr)
  items = document.querySelectorAll("[data-src]")
  return if items.length is 0
  console.log items
  loader = document.querySelectorAll(".delayed-load")
  for i in [0...items.length]
    do (i) ->
      el = items[i]
      src = el.getAttribute("data-src")
      el.setAttribute("src", src)
      window.setTimeout () ->
        el.parentElement.classList.remove("delayed-load")
      , 350
      return

document.onreadystatechange = () ->
  run() if document.readyState is "interactive"
  delayed() if document.readyState is "complete"











