# project template configuration script for basisproject tool

# ------------------------------------------------------------------------------
# load previous template configuration
from imp import load_source
config        = load_source('config_1_0', __file__.replace('1.5', '1.0').replace('.pyc', '.py'))
required      = config.required
options       = config.options
presets       = config.presets
substitutions = config.substitutions
del config

# ------------------------------------------------------------------------------
# additional optional project files
options['test-internal'] = {
  'desc' : 'Add/remove support for internal testing.',
  'path' : 'test/internal/CMakeLists.txt',
  'deps' : 'test'
}
