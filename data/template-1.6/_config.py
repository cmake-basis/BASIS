# project template configuration script for basisproject tool

# ------------------------------------------------------------------------------
# load previous template configuration
from imp import load_source
config   = load_source('config_1_5', __file__.replace('1.6', '1.5').replace('.pyc', '.py'))
required = config.required
options  = config.options
presets  = config.presets
del config

# ------------------------------------------------------------------------------
# additional optional project files
options['doc-rst'] = {
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
}

# ------------------------------------------------------------------------------
# add additional options to selected presets
for preset in ['default', 'toplevel']:
    presets[preset]['args'].extend(['doc-rst'])
