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

import breathe.parser.doxygen.index
import breathe.parser.doxygen.compound
import os

class ParserError(Exception):
    pass

class Parser(object):

    def __init__(self, cache, path_handler):

        self.cache = cache
        self.path_handler = path_handler


class DoxygenIndexParser(Parser):

    def parse(self, project_info):

        filename = self.path_handler.join(project_info.path(), "index.xml")

        try: 
            # Try to get from our cache
            return self.cache[filename]
        except KeyError:

            # If that fails, parse it afresh
            try:
                result = breathe.parser.doxygen.index.parse(filename)
                self.cache[filename] = result
                return result
            except breathe.parser.doxygen.index.ParseError:
                raise ParserError(filename)

class DoxygenCompoundParser(Parser):

    def __init__(self, cache, path_handler, project_info):
        Parser.__init__(self, cache, path_handler)

        self.project_info = project_info

    def parse(self, refid):

        filename = self.path_handler.join(self.project_info.path(), "%s.xml" % refid)

        try: 
            # Try to get from our cache
            return self.cache[filename]
        except KeyError:

            # If that fails, parse it afresh
            try:
                result = breathe.parser.doxygen.compound.parse(filename)
                self.cache[filename] = result
                return result
            except breathe.parser.doxygen.compound.ParseError:
                raise ParserError(filename)

class CacheFactory(object):

    def create_cache(self):

        # Return basic dictionary as cache
        return {}

class DoxygenParserFactory(object):

    def __init__(self, cache, path_handler):

        self.cache = cache
        self.path_handler = path_handler

    def create_index_parser(self):

        return DoxygenIndexParser(self.cache, self.path_handler)

    def create_compound_parser(self, project_info):

        return DoxygenCompoundParser(self.cache, self.path_handler, project_info)



