
fs = require('fs')
path = require('path')
_ = require('underscore')

builds = {}
groups = {}


task 'all', 'compile target files', (options)->
  for target, action of builds
    action.call @, options

task 'clean', 'rm target files', ->
  for target of builds
    try
      fs.unlinkSync target
    catch
      null

_(global).extend
  _: _
  make: (target, depend, action)->
    
    group = null
    descript = null
    
    if target.indexOf(':') > 0
      [group, descript, target] = target.split ':'
      [descript, target] = [target, descript] unless target
      
    depend = [depend] if _(depend).isString()

    builds[target] = (options)->
      auto_val = ->
      _.extend auto_val, 
        '@': target
        '^': _.uniq(depend)
        '<': _.first(depend)
        '?': depend
        '+': depend
        '*': _(depend).map (d)-> path.join path.dirname(d), path.basename(d, path.extname(d))
        exec: (cmd)->
          console.log cmd
          require('child_process').exec cmd

        

      try
        tfs = fs.statSync target
      catch
        return action(auto_val)

      auto_val['?'] = []
      for df in depend
        try
          dfs = fs.statSync df
        catch error
          console.log "file not found: #{error.path}"
          continue
        continue if dfs.mtime < tfs.mtime
        
        auto_val['?'].push df

      action(auto_val) if auto_val['?'].length

    return task target, "make #{target}", builds[target] unless group

    if _(groups).has group
      groups[group].push builds[target]
    else
      groups[group] = [ builds[target] ]
      task group, descript, (options)->
        for build in groups[group]
          build.call @, options

module.exports = exports = ->
