# Description
#   Confluence/Wiki searches
#
# Configuration:
#   HUBOT_CONFLUENCE_USER - (required)
#   HUBOT_CONFLUENCE_PASSWORD - (required)
#   HUBOT_CONFLUENCE_HOST - (required) - confluence hostname or alias (wiki.example.com)
#   HUBOT_CONFLUENCE_PROTOCOL - defaults to https
#   HUBOT_CONFLUENCE_SEARCH_SPACE -(optional) limit searches to a particular space
#   HUBOT_CONFLUENCE_CONTEXT - (optional)- often '/wiki' - defaults to ''
#   HUBOT_CONFLUENCE_AUTH - (optional) defaults to 'basic'
#   HUBOT_CONFLUENCE_SEARCH_LIMIT - (optional) - max number of returned results - defaults to '5'
#   HUBOT_CONFLUENCE_HEARD_LIMIT - (optional) - max number of suggestions - defaults to '3'
#   HUBOT_CONFLUENCE_HIGHLIGHT_MARKDOWN_REPLACEMENT - (optional) - Replace the @@@hl@@@ markdown with something else.
#
# Commands:
#   hubot wiki <search term(s)> - Hubot provides pages 
#
# Notes:
# See https://docs.atlassian.com/confluence/REST/latest/ for more info on available 
#
# Author:
#   ParadoxGuitarist

confluence_user = process.env.HUBOT_CONFLUENCE_USER
confluence_password = process.env.HUBOT_CONFLUENCE_PASSWORD
confluence_host = process.env.HUBOT_CONFLUENCE_HOST
confluence_context = process.env.HUBOT_CONFLUENCE_CONTEXT or ''
confluence_protocol = process.env.HUBOT_CONFLUENCE_PROTOCOL or 'https'
confluence_auth = process.env.HUBOT_CONFLUENCE_AUTH or 'basic'
confluence_search_limit = process.env.HUBOT_CONFLUENCE_SEARCH_LIMIT or '5'
confluence_heard_limit = process.env.HUBOT_CONFLUENCE_HEARD_LIMIT or '3'
confluence_highlight = process.env.HUBOT_CONFLUENCE_HIGHLIGHT_MARKDOWN_REPLACEMENT or ''
confluence_search_space = process.env.HUBOT_CONFLUENCE_SEARCH_SPACE or ''
hellip = "[...]"

searchspace =
  if confluence_search_space == ''
    searchspace = ''
  else
    searchspace = "AND(space+in+(#{confluence_search_space}))"
ConfluenceBaseURL = "#{confluence_protocol}://#{confluence_host}#{confluence_context}"
authsuffix = "os_authType=#{confluence_auth}"
auth = 'Basic ' + new Buffer("#{confluence_user}:#{confluence_password}").toString('base64');

confluence_request = (msg, url, handler) ->
  msg.http("#{ConfluenceBaseURL}#{url}")
    .headers(Authorization: auth, Accept: 'application/json')
    .get() (err, res, body) ->
      if err
        msg.send "Confluence reports error: #{err}"
        return
      if res.statusCode isnt 200
        msg.send "Request Failed. Sorry."
        return
      content = JSON.parse(body)
      handler content

module.exports = (robot) ->

  robot.respond /wiki (.*)$/i, (msg) ->
    search_term = msg.match[1]
    confluence_request msg, "/rest/api/search?#{authsuffix}&cql=(type=page)#{searchspace}AND(text~'#{search_term}')&limit=#{confluence_search_limit}", (result) ->
      if result.error
        msg.send result.description
        return
      message = "Showing #{result.size} results: out of #{result.totalSize} - #{result._links.base}/dosearchsite.action?cql=#{result.cqlQuery.replace /(\s)/g, '+'}"
      message += "\n*#{i.content.title}* #{ConfluenceBaseURL}#{i.content._links.tinyui}\n>#{i.excerpt}" for i in result.results
      message = message.replace /@@@hl@@@|@@@endhl@@@/g, confluence_highlight
      message = message.replace /&hellip;/g, hellip	
      msg.send message

  robot.hear /(?:how do i|how do you) (.*)$/i, (msg) ->
    search_term = msg.match[1].replace(/\s(the |and |on |like |as |a )|\?|\,|\./g, ' ')
    confluence_request msg, "/rest/api/search?#{authsuffix}&cql=(type=page)#{searchspace}AND(text~'#{search_term}')&limit=#{confluence_heard_limit}", (result) ->
      if result.error
        msg.send result.description
        return
      if result.size == '0'
        msg.send "Perhaps you should try this: http://lmgtfy.com/?q=#{search_term.replace /\s/g, '+'}"
        return
      message = "Not sure I know how to do that, but this might help:"
      message += "\n*#{i.content.title}* #{ConfluenceBaseURL}#{i.content._links.tinyui}\n>#{i.excerpt}" for i in result.results
      message = message.replace /@@@hl@@@|@@@endhl@@@/g, confluence_highlight
      message = message.replace /&hellip;/g, hellip
      message += "\n_You could always try searches here:_ http://lmgtfy.com/?q=#{search_term.replace /(\s)/g, '+'} #{result._links.base}/dosearchsite.action?cql=#{result.cqlQuery.replace /(\s)/g, '+'}_"
      msg.send message
