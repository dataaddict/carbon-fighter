module.exports = (from, to) ->
  unless to
    to = from
    from = 0
  Math.random!*(to - from) + from
  
if process.argv.1 == __filename
  for til 100
    r = module.exports 2
    console.log r
