# project template configuration script for basisproject tool

# ------------------------------------------------------------------------------
# required project files
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
# optional project files
options = {
  # additional configuration files
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
  # software data
  'data' : {
    'desc' : 'Add/remove directory for auxiliary data files.',
    'path' : [ 'data/CMakeLists.txt' ]
  },
  # documentation
  'doc' : {
    'desc' : 'Add/remove directory for documentation files.',
    'path' : [
               'doc/CMakeLists.txt',
               'doc/doxygen_extra.css.in',
               'doc/doxygen_header.html.in',
               'doc/doxygen_footer.html.in',
               'doc/logo.png'
             ]
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
    'path' : [ 'example/CMakeLists.txt' ]
  },
  # project modules
  'modules' : {
    'desc' : 'Add/remove support for modularization.',
    'path' : [ 'modules/' ]
  },
  # source files
  'include' : {
    'desc' : 'Add/remove directory for public header files.',
    'path' : [ 'include/' ]
  },
  'src' : {
    'desc' : 'Add/remove directory for project source files.',
    'path' : [ 'src/CMakeLists.txt' ]
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
# preset template options
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
# additional substitutions besides <project>, <template>,...
from datetime import datetime as date

substitutions = {
  # fixed computed substitutions
  'date'  : date.today().strftime('%x'),
  'day'   : date.today().day,
  'month' : date.today().month,
  'year'  : date.today().year,
  # substitutions which can be overridden using a command option
  'vendor' : {
    'help'    : "Package vendor ID (e.g., acronym of provider and/or division).",
    'default' : "basis"
  },
  'provider-name' : {
    'help'    : "Name of the package provider.",
    'default' : "provider-name"
  },
  'provider-website' : {
    'help'    : "Website of the package provider.",
    'default' : "http://www.provider-website.com"
  },
  'provider-logo' : {
    'help'    : "Logo of the package provider.",
    'default' : ""
  },
  'division-name' : {
    'help'    : "Name of the package provider division, group, or project name.",
    'default' : ""
  },
  'division-website' : {
    'help'    : "Website of the package provider division, group, or project name.",
    'default' : ""
  },
  'division-logo' : {
    'help'    : "Logo of the package provider division, group, or project name.",
    'default' : ""
  },
  'copyright' : {
    'help'    : "Copyright statement optionally including years, but not \". All rights reserved.\".",
    'default' : str(date.today().year) + " provider-name"
  },
  'license' : {
    'help'    : "Package licensing terms, or where to find the detailed license.",
    'default' : "See COPYING file."
  },
  'ctest-drop-site' : {
    'help'    : "Website for ctest test execution.",
    'default' : ""
  },
  'contact' : {
    'help'    : "Contact information to reach someone regarding this package.",
    'default' : "Contact Name <contact@name.com>"
  }
}

del date
