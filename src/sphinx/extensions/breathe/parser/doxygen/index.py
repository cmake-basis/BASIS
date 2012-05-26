# Copied from breathe package on 5/26/2012
# https://github.com/michaeljones/breathe
# ----------------------------------------------------------------------------
# Copyright (c) 2009, Michael Jones
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#	 * Redistributions of source code must retain the above copyright notice,
#	   this list of conditions and the following disclaimer.
#	 * Redistributions in binary form must reproduce the above copyright notice,
#	   this list of conditions and the following disclaimer in the documentation
#	   and/or other materials provided with the distribution.
#	 * The names of its contributors may not be used to endorse or promote
#	   products derived from this software without specific prior written
#	   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ----------------------------------------------------------------------------

"""
Generated Mon Feb  9 19:08:05 2009 by generateDS.py.
"""

from xml.dom import minidom


import indexsuper as supermod

class DoxygenTypeSub(supermod.DoxygenType):

    node_type = "doxygen"

    def __init__(self, version=None, compound=None):
        supermod.DoxygenType.__init__(self, version, compound)
supermod.DoxygenType.subclass = DoxygenTypeSub
# end class DoxygenTypeSub


class CompoundTypeSub(supermod.CompoundType):
    
    node_type = "compound"

    def __init__(self, kind=None, refid=None, name='', member=None):
        supermod.CompoundType.__init__(self, kind, refid, name, member)
supermod.CompoundType.subclass = CompoundTypeSub
# end class CompoundTypeSub


class MemberTypeSub(supermod.MemberType):

    node_type = "member"

    def __init__(self, kind=None, refid=None, name=''):
        supermod.MemberType.__init__(self, kind, refid, name)
supermod.MemberType.subclass = MemberTypeSub
# end class MemberTypeSub


class ParseError(Exception):
    pass

def parse(inFilename):

    try:
        doc = minidom.parse(inFilename)
    except IOError, e:
        raise ParseError(inFilename)
       
    rootNode = doc.documentElement
    rootObj = supermod.DoxygenType.factory()
    rootObj.build(rootNode)

    return rootObj

