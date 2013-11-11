# project template configuration script for basisproject tool

# ------------------------------------------------------------------------------
# load previous template configuration
from imp import load_source
config        = load_source('config_1_6', __file__.replace('1.8', '1.6').replace('.pyc', '.py'))
required      = config.required
options       = config.options
presets       = config.presets
substitutions = config.substitutions
del config

# ------------------------------------------------------------------------------
# additional optional project files
options['doc']['path'].extend(
  [
    'doc/doxygen_extra.css',
    'doc/penn_logo.gif',
    'doc/sbia_logo.png'
  ]
)
