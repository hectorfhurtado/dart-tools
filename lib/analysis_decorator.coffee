_       = require 'lodash'

module.exports =
class AnalysisDecorator
  constructor: (@analysisComponent) ->
    that = this

    atom.workspace.eachEditor (editor) =>
      fullPath = editor.getPath()
      results = that.analysisComponent.analysisResultsMap[fullPath] || []
      for result in results
        if fullPath == result.location.file
          that.decorateEditor(result, editor)

  addDecoratorForAnalysis: (result) ->
    for editor in atom.workspace.getEditors()
      if editor.getPath() == result.location.file
        @decorateEditor(result, editor)
        return

  decorateEditor: (result, editor) ->
    loc = result.location
    fullpath = loc.file

    category = result.severity.toLowerCase()
    line = loc.startLine   - 1;
    col  = loc.startColumn - 1
    css = "dart-analysis-#{category}"
    marker = editor.markBufferRange [
      [line, col],
      [line, col + loc.length]
    ]

    @annotateMarker(marker, result)

    editor.decorateMarker marker,
      type: 'gutter',
      class: css

    editor.decorateMarker marker,
      type: 'highlight',
      class: css

    @emit 'marker-added',
      marker: marker
      editor: editor

  refreshDecoratorsForPath: (fullPath) ->
    for editor in atom.workspace.getEditors()
      if editor.getPath() == fullPath
        markers = editor.findMarkers(isDartMarker: true)
        _.invoke markers, 'destroy'
        return

  annotateMarker: (marker, analysisResult) ->
    marker.setAttributes
      isDartMarker: true
      analysisResult: analysisResult


  isDartMarker: (marker) ->
    marker.getAttributes().isDartMarker == true
