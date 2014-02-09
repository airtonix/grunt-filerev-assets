###
 * grunt-filerev-assets
 * https://github.com/richardbolt/grunt-filerev-assets
 *
 * Copyright (c) 2013 Richard Bolt
 * Licensed under the MIT license.
###

_ = require "lodash"

stripPrefixFromObj = (obj, options) ->
  assets = {}
  for own value, key of obj
    if options.cwd
      if key.substr 0, options.cwd.length is options.cwd
        key = key.substr options.cwd.length

      if options.cwd is value.substr 0, options.cwd.length
        value = value.substr options.cwd.length

      assets[key] = value

  return assets


addPrefixToObj = (obj, options) ->
  assets = {}
  for own value, key in obj
    if options.prefix
      value = options.prefix + value

    assets[key] = value

  return assets


module.exports = (grunt) ->

  task = () ->
    self = this
    spaces = 0
    options = self.options
          dest: 'assets.json'  # Writes to this file.
          prettyPrint: false   # human readable output format
          patterns: null       # list of regexs, array of strings, or functions to process

      # // We must have run filerev in some manner first.
      # // If we do this: grunt.task.requires('filerev');
      # // then if we ran filerev:action we will fail out,
      # // when we don't want to. This just checks for the presence of the
      # // grunt.filerev object and fails if it's not present.
      # // You can override the warning with the --force command line option.

      if !grunt.filerev || !grunt.filerev.summary
        grunt.fail.error 'Could not find grunt.filerev.summary. Required task "filerev" must be run first.'
        return

      if !options.dest || !grunt.filerev.summary
        grunt.log.error 'No destination provided.'
        return

      assets = grunt.filerev.summary
      assetsOut = {}

      for key, value of assets
        item =
          key: key
          value: value

        for pattern in options.patterns
          do (pattern) ->

            if _.isArray(pattern)
              item.key = item.key.replace pattern[0], pattern[1]
              item.value = item.value.replace pattern[0], pattern[1]

            if _.isFunction(pattern)
              output = pattern item

        if item
          assetsOut[item.key] = item.value

      if options.prettyPrint
        if _.isNumber(options.prettyPrint)
          spaces = options.prettyPrint
        else
          spaces = 4

      grunt.file.write options.dest, JSON.stringify(assetsOut, null, spaces)
      grunt.filerevassets = assetsOut
      grunt.log.writeln 'File', options.dest, 'created.'

  grunt.registerMultiTask 'filerev_assets', 'Record asset paths from grunt-filerev to a json file', task
