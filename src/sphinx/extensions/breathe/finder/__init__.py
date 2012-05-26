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

class FinderError(Exception):
    pass

class MultipleMatchesError(FinderError):
    pass

class NoMatchesError(FinderError):
    pass

class Finder(object):

    def __init__(self, root, item_finder_factory):

        self._root = root
        self.item_finder_factory = item_finder_factory

    def find(self, matcher_stack):

        item_finder = self.item_finder_factory.create_finder(self._root)

        return item_finder.find(matcher_stack)

    def filter_(self, filter_, matches):

        item_finder = self.item_finder_factory.create_finder(self._root)
        item_finder.filter_(filter_, matches)

    def find_one(self, matcher_stack):

        results = self.find(matcher_stack)

        count = len(results)
        if count == 1:
            return results[0]
        elif count > 1:
            # Multiple matches can easily happen as same thing
            # can be present in both file and group sections
            return results[0]
        elif count < 1:
            raise NoMatchesError(matcher_stack)


    def root(self):

        return self._root


class FinderFactory(object):

    def __init__(self, parser, item_finder_factory_creator):

        self.parser = parser
        self.item_finder_factory_creator = item_finder_factory_creator


    def create_finder(self, project_info):

        root = self.parser.parse(project_info)
        item_finder_factory = self.item_finder_factory_creator.create_factory(project_info)

        return Finder(root, item_finder_factory)



