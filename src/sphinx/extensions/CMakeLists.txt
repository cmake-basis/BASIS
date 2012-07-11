##############################################################################
# @file  CMakeLists.txt
# @brief Build configuration of Sphinx extensions.
#
# Copyright (c) 2012 University of Pennsylvania. All rights reserved.<br />
# See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
#
# Contact: SBIA Group <sbia-software at uphs.upenn.edu>
##############################################################################

# ----------------------------------------------------------------------------
# breathe
basis_add_library (
  breathe
    breathe/__init__.py
    breathe/finder/__init__.py
    breathe/finder/doxygen/__init__.py
    breathe/finder/doxygen/base.py
    breathe/finder/doxygen/compound.py
    breathe/finder/doxygen/index.py
    breathe/parser/__init__.py
    breathe/parser/doxygen/__init__.py
    breathe/parser/doxygen/compound.py
    breathe/parser/doxygen/compoundsuper.py
    breathe/parser/doxygen/index.py
    breathe/parser/doxygen/indexsuper.py
    breathe/renderer/__init__.py
    breathe/renderer/rst/__init__.py
    breathe/renderer/rst/doxygen/__init__.py
    breathe/renderer/rst/doxygen/base.py
    breathe/renderer/rst/doxygen/compound.py
    breathe/renderer/rst/doxygen/domain.py
    breathe/renderer/rst/doxygen/filter.py
    breathe/renderer/rst/doxygen/index.py
    breathe/renderer/rst/doxygen/target.py
)

basis_set_target_properties (breathe PROPERTIES PREFIX "${SPHINX_EXTENSIONS_PREFIX}")

# ----------------------------------------------------------------------------
# doxylink
basis_add_library (
  doxylink
    doxylink/__init__.py
    doxylink/doxylink.py
    doxylink/parsing.py
    doxylink/pyparsing.py
)

basis_set_target_properties (doxylink PROPERTIES PREFIX "${SPHINX_EXTENSIONS_PREFIX}")
