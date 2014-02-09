require('./src/cheese-cake')

_([0..99]).each (i)->
  i = if i.toString().length > 1 then i else '0' + i
  make "js:compile javascripts:./lib/cheese-cake.#{i}.js", './src/cheese-cake.coffee', ($)->
    console.log cmd = "coffee -p #{$['+']} > #{$['@']}"
    $.exec cmd
  
make './lib/cheese-cake.js', './src/cheese-cake.coffee', ($)->
  $.exec "coffee -o ./lib #{$['+']}"
