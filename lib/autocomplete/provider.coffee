{filter} = require 'fuzzaldrin'

AutoCompletePlusProvider =
  selector: '.source.dart'
  disableForSelector: '.source.dart .comment'

  inclusionPriority: 1
  excludeLowerPriority: true

  # Our analysis API service object
  analysisApi: null

  # Required: Return a promise, an array of suggestions, or null.
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    new Promise (resolve) =>
      if @analysisApi
        path = editor.getPath()
        offset = editor.buffer.characterIndexForPosition(bufferPosition)

        @analysisApi.updateFile path, editor.getText()
        @analysisApi.completion.getSuggestions(path, offset)
          .then (autocompleteInfo) ->
            items = []
            results = autocompleteInfo.params.results
            sortedResults = filter(results, prefix, { key: 'completion'})

            for result in sortedResults
              items.push
                text: result.completion,
                rightLabel: result.element.kind

            resolve(items)


  # (optional): called _after_ the suggestion `replacementPrefix` is replaced
  # by the suggestion `text` in the buffer
  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  # (optional): called when your provider needs to be cleaned up. Unsubscribe
  # from things, kill any processes, etc.
  dispose: ->


module.exports = AutoCompletePlusProvider
