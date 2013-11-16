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
    'path' : [
               'doc/CMakeLists.txt',
               'doc/doxygen_extra.css',
               'doc/penn_logo.gif',
               'doc/sbia_logo.png'
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
    'args' : [ 'src' ]
  },
  'default' : {
    'desc' : 'Choose default project template.',
    'args' : [ 'doc', 'doc-rst', 'example', 'include', 'src', 'test' ]
  },
  'toplevel' : {
    'desc' : 'Create toplevel project.',
    'args' : [ 'doc', 'doc-rst', 'example', 'modules' ]
  },
  'module' : {
    'desc' : 'Create module of toplevel project.',
    'args' : [ 'include',   'src',   'test' ]
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
    'default' : "SBIA"
  },
  'provider-name' : {
    'help'    : "Name of the package provider.",
    'default' : "University of Pennsylvania"
  },
  'provider-website' : {
    'help'    : "Website of the package provider.",
    'default' : "http://www.upenn.edu"
  },
  'provider-logo' : {
    'help'    : "Logo of the package provider.",
    'default' : "penn_logo.gif"
  },
  'division-name' : {
    'help'    : "Name of the package provider division.",
    'default' : "Section of Biomedical Image Analysis"
  },
  'division-website' : {
    'help'    : "Website of the package provider division.",
    'default' : "http://www.upenn.edu/sbia/"
  },
  'division-logo' : {
    'help'    : "Logo of the package provider division.",
    'default' : "sbia_logo.png"
  },
  'copyright' : {
    'help'    : "Copyrigth statement optionally including years, but not \". All rights reserved.\".",
    'default' : str(substitutions['year']) + " University of Pennsylvania"
  },
  'license' : {
    'help'    : "Copyrigth statement including years, but excluding \"All rights reserved.\".",
    'default' : "See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file."
  },
  'contact' : {
    'help'    : "Package contact information.",
    'default' : "SBIA Group <sbia-software at uphs.upenn.edu>"
  }
}

del date
