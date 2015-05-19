spawn = require('child_process').spawn
path  = require 'path'

module.exports =
class Utils
  @whenEditor: (fxn) =>
    editor = atom.workspace.getActiveEditor()
    fxn(editor) if editor

  @dartSdkPath: =>
    atom.config.get 'dart-tools.dartSdkLocation' ||
      process.env.DART_SDK ||
      ''

  @dartSdkInfo: (fxn) =>
    sdkInfo =
      sdkPath: atom.config.get 'dart-tools.dartSdkLocation'
      envPath: process.env.DART_SDK
    if fxn
      @dartVersion (dartVersion) =>
        sdkInfo.version = dartVersion
        fxn(sdkInfo)

    sdkInfo

  @dartVersion: (fxn) =>
    buffer = ''
    sdkPath = @dartSdkPath()
    execPath = if sdkPath then path.join(sdkPath, 'bin', 'dart') else 'dart'
    @whenDartSdkFound =>
      process = spawn execPath, ['--version']
      exitCode = -1;

      process.stderr.on 'data', (data) => buffer += data.toString()
      process.stderr.on 'end', => fxn(buffer)

  @whenDartProject: (fxn) =>
    fxn() if @isDartProject()

  @isDartProject: =>
    rootDirectory = atom.project.getDirectories()[0]
    return false unless rootDirectory
    pubspec = rootDirectory.getFile('pubspec.yaml')
    pubspec.existsSync()

  @isDartFile: (filename = '') =>
    path.extname(filename) == '.dart'

  @isCompatible: (editor) =>
    # We only support pure Dart files for now
    @isDartFile editor.getPath()

  @whenDartSdkFound: (fxn) =>
    # Why is process null??
    process = window.process unless process
    if process
      sdkPath = @dartSdkPath()

      isWindows  = process.platform == 'win32'
      whereCmd   = if isWindows then 'where' else 'which'
      @executableExtension = if isWindows then '.exe' else ''
      @toolsExtension = if isWindows then '.bat' else ''

      if sdkPath
        execPath = path.join(sdkPath, 'bin', 'dart' + executableExtension)
        process = spawn whereCmd, [execPath]

        process.on 'exit', (code) =>
          if code == 0
            fxn()
          else
            atom.workspace.emit 'dart-tools:cannot-find-sdk', @dartSdkInfo()
      else
        atom.workspace.emit 'dart-tools:cannot-find-sdk', @dartSdkInfo()
