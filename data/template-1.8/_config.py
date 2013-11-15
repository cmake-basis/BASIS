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

# ------------------------------------------------------------------------------
# additional substitutions
substitutions['vendor'] = {
  'help'    : "Package vendor ID (e.g., acronym of provider and/or division).",
  'default' : "SBIA"
}
substitutions['provider-name'] = {
  'help'    : "Name of the package provider.",
  'default' : "University of Pennsylvania"
}
substitutions['provider-website'] = {
  'help'    : "Website of the package provider.",
  'default' : "http://www.upenn.edu"
}
substitutions['provider-logo'] = {
  'help'    : "Logo of the package provider.",
  'default' : "penn_logo.gif"
}
substitutions['division-name'] = {
  'help'    : "Name of the package provider division.",
  'default' : "Section of Biomedical Image Analysis"
}
substitutions['division-website'] = {
  'help'    : "Website of the package provider division.",
  'default' : "http://www.upenn.edu/sbia/"
}
substitutions['division-logo'] = {
  'help'    : "Logo of the package provider division.",
  'default' : "sbia_logo.png"
}
substitutions['copyright'] = {
  'help'    : "Copyrigth statement optionally including years, but not \". All rights reserved.\".",
  'default' : str(substitutions['year']) + " University of Pennsylvania"
}
substitutions['license'] = {
  'help'    : "Copyrigth statement including years, but excluding \"All rights reserved.\".",
  'default' : "See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file."
}
substitutions['contact'] = {
  'help'    : "Package contact information.",
  'default' : "SBIA Group <sbia-software at uphs.upenn.edu>"
}
