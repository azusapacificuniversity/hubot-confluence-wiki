# hubot-confluence-wiki

Confluence/Wiki searches

See [`src/confluence-wiki.coffee`](src/confluence-wiki.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-confluence-wiki --save`

Then add **hubot-confluence-wiki** to your `external-scripts.json`:

```json
["hubot-confluence-wiki"]
```

## Sample Interaction

```
user1>> hubot wiki supported programs
hubot>> Showing 3 results: out of 20 - https://wiki.domain.com/dosearchsite.action?supported+programs
	*Page1* https://wiki.domain.com/x/tinyurl1
	><excerpt from page>
	*Page2* https://wiki.domain.com/x/tinyurl2
	><excerpt from page>
	*Page3* https://wiki.domain.com/x/tinyurl3
	><excerpt from page>

```
# Configuration:
```
HUBOT_CONFLUENCE_USER - (required)
HUBOT_CONFLUENCE_PASSWORD - (required)
HUBOT_CONFLUENCE_HOST - (required) - confluence hostname or alias (wiki.example.com)
HUBOT_CONFLUENCE_PROTOCOL - defaults to https
HUBOT_CONFLUENCE_SEARCH_SPACE -(optional) limit searches to a particular space
HUBOT_CONFLUENCE_CONTEXT - (optional)- often '/wiki' - defaults to ''
HUBOT_CONFLUENCE_AUTH - (optional) defaults to 'basic'
HUBOT_CONFLUENCE_SEARCH_LIMIT - (optional) - max number of returned results - defaults to '5'
HUBOT_CONFLUENCE_HEARD_LIMIT - (optional) - max number of suggestions - defaults to '3'
HUBOT_CONFLUENCE_HIGHLIGHT_MARKDOWN_REPLACEMENT - (optional) - Replace the @@@hl@@@ markdown with something else.
```
