# project template configuration script for basisproject tool

# ------------------------------------------------------------------------------
# required project files
required = [
  'AUTHORS.txt',
  'README.txt',
  'INSTALL.txt',
  'COPYING.txt',
  'CMakeLists.txt',
  'BasisProject.cmake'
]

# ------------------------------------------------------------------------------
# optional project files
options = {
  'config-settings' : {
    'desc' : 'Include/exclude custom Settings.cmake file.',
    'path' : [ 'config/Settings.cmake' ]
  },
  'config-depends' : {
    'desc' : 'Include/exclude custom Depends.cmake file.',
    'path' : [ 'config/Depends.cmake' ]
  },
  'config-components' : {
    'desc' : 'Include/exclude custom Components.cmake file.',
    'path' : [ 'config/Components.cmake' ]
  },
  'config-package' : {
    'desc' : 'Include/exclude custom Package.cmake file.',
    'path' : [ 'config/Package.cmake' ]
  },
  'config-find' : {
    'desc' : 'Include/exclude custom Config.cmake.in file.',
    'path' : [
               'config/Config.cmake.in',
               'config/ConfigSettings.cmake'
             ]
  },
  'config-find-version' : {
    'desc' : 'Include/exclude custom ConfigVersion.cmake.in file.',
    'path' : [ 'config/ConfigVersion.cmake.in' ]
  },
  'config-script' : {
    'desc' : 'Include/exclude custom ScriptConfig.cmake.in file.',
    'path' : [ 'config/ScriptConfig.cmake.in' ]
  },
  'config-test' : {
    'desc' : 'Include/exclude custom CTestCustom.cmake.in file.',
    'path' : [ 'config/CTestCustom.cmake.in' ]
  },
  'config-use' : {
    'desc' : 'Include/exclude custom ConfigUse.cmake.in file.',
    'path' : [ 'config/ConfigUse.cmake.in' ]
  },
  'config' : {
    'desc' : 'Include/exclude all custom configuration files.',
    'deps' : [
               'config-settings',
               'config-depends',
               'config-components',
               'config-package',
               'config-find',
               'config-find-version',
               'config-script',
               'config-test',
               'config-use'
             ]
  },
  'data' : {
    'desc' : 'Add/remove directory for auxiliary data files.',
    'path' : [ 'data/CMakeLists.txt' ]
  },
  'doc' : {
    'desc' : 'Add/remove directory for documentation files.',
    'path' : [ 'doc/CMakeLists.txt' ]
  },
  'example' : {
    'desc' : 'Add/remove directory for example files.',
    'path' : [ 'example/CMakeLists.txt' ]
  },
  'modules' : {
    'desc' : 'Add/remove support for modularization.',
    'path' : [ 'modules/' ]
  },
  'include' : {
    'desc' : 'Add/remove directory for public header files.',
    'path' : [ 'include/' ]
  },
  'src' : {
    'desc' : 'Add/remove directory for project source files.',
    'path' : [ 'src/CMakeLists.txt' ]
  },
  'test' : {
    'desc' : 'Add/remove support for testing.',
    'path' : [
               'CTestConfig.cmake',
               'test/CMakeLists.txt'
             ]
  }
}

# ------------------------------------------------------------------------------
# preset template options
presets = {
  'minimal' : {
    'desc' : 'Choose minimal project template.',
    'args' : [ 'src' ]
  },
  'default' : {
    'desc' : 'Choose default project template.',
    'args' : [ 'doc', 'example', 'include', 'src', 'test' ]
  },
  'toplevel' : {
    'desc' : 'Create toplevel project.',
    'args' : [ 'doc', 'example', 'modules' ]
  },
  'module' : {
    'desc' : 'Create module of toplevel project.',
    'args' : [ 'include',   'src',   'test' ]
  }
}

# ------------------------------------------------------------------------------
# additional substitutions besides <project>, <template-version>,...
from datetime import datetime as date

substitutions = {
  'date'  : date.today().strftime('%x'),
  'day'   : date.today().day,
  'month' : date.today().month,
  'year'  : date.today().year
}

del date
