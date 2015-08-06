Git = require 'git-wrapper'
path = require 'path'
fs = require 'fs'

showOpts =
  s: true
  format: '%ce####%s####%cn####%b'

cache = {}

getCache = (file, hash) ->
  cache["#{file}|#{hash}"] || null

setCache = (file, hash, msg) ->
  cache["#{file}|#{hash}"] = msg

findRepo = (cpath) ->
  while cpath and lastPath isnt cpath
    lastPath = cpath
    cpath = path.dirname cpath

    rpath = path.join(cpath, '.git')
    return rpath if fs.existsSync rpath

  return null

getCommitMessage = (file, hash, callback) ->
  repoPath = findRepo(file)

  return unless repoPath

  git = new Git('git-dir': repoPath)
  git.exec 'show', showOpts, [hash], (error, msg) ->
    return if error

    callback msg

getCommit = (file, hash, callback) ->
  cached = getCache(file, hash)
  return callback(cached) if cached

  getCommitMessage file, hash, (msg) ->

    lines = msg.split /####/g

    commit =
      email: lines.shift()
      subject: lines.shift()
      author: lines.shift()
      message: lines.join('\n').replace(/(^\s+|\s+$)/g, '')

    setCache(file, hash, commit)

    callback commit


module.exports = getCommit