{ CompositeDisposable, File } = require 'atom'

module.exports = SwitchExtension =
  subscriptions: null

  config:
    fileExtensions:
      type: 'array'
      title: 'Extensions'
      description: 'The extensions to switch between in the same directory'
      default: ['.js', '.html', '.css']
      items:
        type: 'string'
        default: '.'

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    # Register command that actives this
    @subscriptions.add atom.commands.add 'atom-text-editor', 'switch-extension:switch': => @switch()

  deactivate: ->
    @subscriptions.dispose()

  switch: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    currentFilePath = editor.getPath()
    return unless currentFilePath

    fileExtensions = atom.config.get('atom-switch-extension.fileExtensions')
    currentExtension = currentFilePath.match(/(\.\w+$)/)[0]
    currentIndex = fileExtensions.indexOf(currentExtension)

    # console.log 'Switching extension on file %o with extensions %o', currentFilePath, fileExtensions

    relatedExtensions = fileExtensions.slice(currentIndex + 1).concat(fileExtensions.slice(0, currentIndex))

    for extension in relatedExtensions
      newFile = new File(currentFilePath.replace(currentExtension, extension))
      if currentExtension != extension && newFile.existsSync()
        atom.workspace.open(newFile.getPath())
        break
