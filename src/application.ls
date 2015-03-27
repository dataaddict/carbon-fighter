global <<< require "prelude-ls"

require! {
  victor: Victor
  d3
  bluebird: Promise
  './rand'
  'moumar-lib/p'
}

$vis = d3.select \svg
vis = $vis.node!
bubbles = []

height = 768
remove-bubbles = (count) ->
  each (.disappear!), bubbles[0 til count]
  bubbles.splice 0, count

$playground = d3.select \.playground
$splash = d3.select \.splash
#$playground.on \click, ->
#  remove-bubbles rand 10

$playground.on \dragover, ->
  d3.event.prevent-default!
  # node!add-event-listener 'drop', fn, false

class Bubble
  (@r = 25) ->
    # @pos = Victor (rand @r, vis.offset-width - @r), (rand @r, vis.offset-height - @r)
    # compute-speed = -> (rand 1, 2)*((parse-int(rand 2)*2)-1)
    @pos = Victor (vis.offset-width - @r)*0.29, (vis.offset-height - @r)*0.18
    @speed = Victor 0, -(rand 1, 4)
    @speed.rotate-deg rand(-60, 60)
    @el = $vis
      .append \circle
      .attr \class, \bubble
      .attr \r, 0
    @el
      .transition!
      .duration 1500
      .attr \r, @r
  disappear: ->
    @el
      .style \opacity, 0.5
      .transition!
      .duration 1500
      .style \opacity, 0
      .attr \r, 0 #@r*4
      .remove!
  draw: ->
    # @speed.multiply Victor 0.99, 0.9999
    if @pos.x > (vis.offset-width - @r) or @pos.x <= @r
      @speed.x = -@speed.x
    if @pos.y > (vis.offset-height - @r) or @pos.y <= @r
      @speed.y = -@speed.y
    @pos.add @speed
    @el
      .attr \cx, @pos.x
      .attr \cy, @pos.y

images =
  playground:
    base-path: \playground-carbon-fighter
  splash:
    base-path: \splash-screen
  resultat:
    base-path: \resultat
  eolien:
    base-path: \eolien2
    position: [892, 92]
    score: 200
    count: 0
  biomasse:
    base-path: \biomasse-2
    position: [892, 219]
    score: 200
    count: 0
  solaire:
    base-path: \solaire2
    position: [892, 369]
    score: 200
    count: 0
  hydro:
    base-path: \hydro2
    position: [892, 492]
    score: 200
    count: 0
    
co2-scores = 
  usa:
    score: 5000
    objective: 5000 * (1 - 0.28)
    co2-to-go: parse-int 5000*0.28
  china: 5000
  
load-images = ->
  images
    |> Obj.map (d) ->
      new Promise (resolve, reject) !->
        d.img = new Image
        d.img.onload = ->
          resolve!
        d.img.onerror = ->
          reject "error loading #{d.img.src}"
        d.img.src = "assets/images/#{d.base-path}.png"
    |> Promise.props

load-images!then ->
  d3.select '.bg img' .attr \src, images.playground.img.src
  d3.select '.result-page img' .attr \src, images.resultat.img.src
  d3.select '.splash'
    .attr \src, images.splash.img.src
    .on \click, ->
      p \click
      d3.select '.game'
        .transition!
        .duration 1000
        .style \top, \0px
      d3.select '.splash'
        .transition!
        .duration 1000
        .style \top, -height + \px
      set-timeout do
        -> start-game \usa
        1500
  
  # start-game \usa
.catch ->
  alert it
pos = null
d3.select document.body
  .on \mousemove, ->
    pos := [d3.event.client-x, d3.event.client-y]
start-game = (country) ->
  co2-score = co2-scores[country].co2-to-go
  update-scores = -> 
    d3.select '.score-fuel span' .text co2-score + ' Gt CO2'
    d3.select '.score-ecolo span' .text '-' + (co2-scores[country].co2-to-go - co2-score) + ' Gt CO2'
  update-scores!
  
  drag-item = null
  drag-pos = null
  $playground.on \drop, ->
    console.log d3.event, pos

    co2-score -= drag-item.score
    drag-item.count += 1
    new-img = drag-item.img.clone-node!
    console.log d3.event
    new-img.style <<<
      position: \absolute
      left: d3.event.page-x - new-img.width/2 + \px
      top: d3.event.page-y - new-img.height/2 + \px
      z-index: 0
    document.query-selector \.game .append-child new-img
    remove-bubbles drag-item.score/10
    if co2-score <= 0 #co2-scores[country].co2-to-go
      co2-score := Math.max 0, co2-score
      remove-bubbles bubbles.length
      set-timeout show-end, 1000
    update-scores!

  for let name, img-data of images when img-data.position
    d3.select \.container
      .append \img
      .attr \class, \sprite
      .attr \src, img-data.img.src
      .attr \draggable, \true
      .style \left, img-data.position.0 + \px
      .style \top, img-data.position.1 + \px
      .on \dragstart, ->
        drag-item := img-data
        console.log \dragstart, drag-pos
        
       #d3.event.data-transfer.set-drag-image img-data.img, 30, 30

  last-launch = 0
  last-time = 0
  is-generating-co = true
  draw = (time) ->
    if is-generating-co
      if bubbles.length < 10
        for til 10
          bubbles.push new Bubble rand 10, 30
      else if co2-scores[country].co2-to-go/10 > (bubbles.length - 1)
        if time > last-launch + 100
          bubbles.push new Bubble rand 10, 30
          last-launch := time
      else
        is-generating-co := false

      b = new Bubble
      bubbles.push b
    each (.draw time), bubbles
    last-time := time
    request-animation-frame draw
  draw!

  function show-end
    d3.select \.result-page
      .transition!
      .duration 1000
      .style \top, \0px
    d3.select \.result-page
      ..select \.percent
        #.text -> images.eolien.count
            
