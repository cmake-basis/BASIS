# project template configuration script for basisproject tool

from os.path  import abspath
from datetime import datetime as date

# ------------------------------------------------------------------------------
version = 1.8

# ------------------------------------------------------------------------------
required = [
  # root documentation files
  'AUTHORS.txt',
  'README.txt',
  'INSTALL.txt',
  'COPYING.txt',
  'ChangeLog.txt',
  # root CMake configuration
  'CMakeLists.txt',
  'BasisProject.cmake'
]

# ------------------------------------------------------------------------------
options = {
  # additional configuration files
  'config-settings' : {
    'desc' : 'Include/exclude custom Settings.cmake file.',
    'path' : 'config/Settings.cmake'
  },
  'config-components' : {
    'desc' : 'Include/exclude custom Components.cmake file.',
    'path' : 'config/Components.cmake'
  },
  'config-package' : {
    'desc' : 'Include/exclude custom Package.cmake file.',
    'path' : 'config/Package.cmake'
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
    'path' : 'config/ConfigVersion.cmake.in'
  },
  'config-script' : {
    'desc' : 'Include/exclude custom ScriptConfig.cmake.in file.',
    'path' : 'config/ScriptConfig.cmake.in'
  },
  'config-test' : {
    'desc' : 'Include/exclude custom CTestCustom.cmake.in file.',
    'path' : 'config/CTestCustom.cmake.in'
  },
  'config-use' : {
    'desc' : 'Include/exclude custom ConfigUse.cmake.in file.',
    'path' : 'config/ConfigUse.cmake.in'
  },
  'config' : {
    'desc' : 'Include/exclude all custom configuration files.',
    'deps' : [
               'config-settings',
               'config-components',
               'config-package',
               'config-find',
               'config-find-version',
               'config-script',
               'config-test',
               'config-use'
             ]
  },
  # software data
  'data' : {
    'desc' : 'Add/remove directory for auxiliary data files.',
    'path' : 'data/CMakeLists.txt'
  },
  # documentation
  'doc' : {
    'desc' : 'Add/remove directory for documentation files.',
    'path' : 'doc/CMakeLists.txt'
  },
  'doc-rst' : {
    'desc' : 'Add/remove reStructuredText (.rst) files for software manual/web site.',
    'path' : [
               'doc/CMakeLists.txt',
               'doc/index.rst',
               'doc/changelog.rst',
               'doc/download.rst',
               'doc/installation.rst',
               'doc/manual.rst',
               'doc/publications.rst',
               'doc/people.rst'
             ]
  },
  # usage example
  'example' : {
    'desc' : 'Add/remove directory for example files.',
    'path' : 'example/CMakeLists.txt'
  },
  # project modules
  'modules' : {
    'desc' : 'Add/remove support for modularization.',
    'path' : 'modules/'
  },
  # source files
  'include' : {
    'desc' : 'Add/remove directory for public header files.',
    'path' : 'include/'
  },
  'src' : {
    'desc' : 'Add/remove directory for project source files.',
    'path' : 'src/CMakeLists.txt'
  },
  # testing tree
  'test' : {
    'desc' : 'Add/remove support for testing.',
    'path' : [
               'CTestConfig.cmake',
               'test/CMakeLists.txt'
             ]
  },
  'test-internal' : {
    'desc' : 'Add/remove support for internal testing.',
    'path' : 'test/internal/CMakeLists.txt',
    'deps' : 'test'
  }
}

# ------------------------------------------------------------------------------
# presets
presets = {
  'minimal' : {
    'desc' : 'Choose minimal project template.',
    'args' : [ 'noconfig', 'nodata', 'nodoc', 'nodoc-rst', 'noexample', 'nomodules', 'noinclude', 'src' ]
  },
  'default' : {
    'desc' : 'Choose default project template.',
    'args' : [ 'noconfig', 'nodata', 'doc', 'doc-rst', 'noexample', 'nomodules', 'include', 'src', 'test' ]
  },
  'toplevel' : {
    'desc' : 'Create toplevel project.',
    'args' : [ 'noconfig', 'nodata', 'doc', 'doc-rst', 'noexample', 'modules', 'noinclude', 'nosrc', 'notest' ]
  },
  'module' : {
    'desc' : 'Create module of toplevel project.',
    'args' : [ 'noconfig', 'nodata', 'nodoc', 'nodoc-rst', 'noexample', 'nomodules', 'include', 'src', 'test' ]
  },
  'full' : {
    'desc' : 'Choose project template with all optional files.',
    'args' : [ 'config', 'doc', 'doc-rst', 'example', 'data', 'nomodules', 'include', 'src', 'test', 'test-internal' ]
  }
}

# ------------------------------------------------------------------------------
substitutions = {
  'date'  : date.today().strftime('%x'),
  'day'   : date.today().day,
  'month' : date.today().month,
  'year'  : date.today().year
}
