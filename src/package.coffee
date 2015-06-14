fs = require('fs')
path = require('path')
_ = require('underscore')

class Package
  constructor: (@jsonPath) ->
    @path = path.dirname(@jsonPath)
    @loaded = false

    info = JSON.parse(fs.readFileSync(@jsonPath))

    if info.name?
      @name = info.name
    else
      throw new Error 'package name required'

    if info.main?
      @main = info.main
    else
      throw new Error 'package main required'

    @version = info.version
    @version ?= '0.0.1'

    @config =
      enabled: true

  activate: () ->
    new Promise (resolve, reject) =>
      unless @loaded
        req = path.resolve(@path, @main)
        try
          klass = require(req)
          @exports = new klass()
          @exports.activate()
          @updateTheme(dripcap.theme.scheme)
          @loaded = true

        catch e
          reject(e)
          return

      resolve(this)

  updateTheme: (theme) ->
    if @exports? && @exports.updateTheme?
      @exports.updateTheme theme

  deactivate: () ->
    new Promise (resolve, reject) =>
      if @loaded
        try
          @exports.deactivate()
          @exports = null
          for key of require.cache
            if key.startsWith(@path)
              delete require.cache[key]
          @loadd = false
        catch e
          reject(e)
          return
      resolve(this)

module.exports = Package
