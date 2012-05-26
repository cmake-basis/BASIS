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

from breathe.finder.doxygen.base import ItemFinder 

class DoxygenTypeSubItemFinder(ItemFinder):

    def find(self, matcher_stack):

        compound_finder = self.item_finder_factory.create_finder(self.data_object.compounddef)
        return compound_finder.find(matcher_stack)

    def filter_(self, parent, filter_, matches):

        compound_finder = self.item_finder_factory.create_finder(self.data_object.compounddef)
        compound_finder.filter_(self.data_object, filter_, matches)


class CompoundDefTypeSubItemFinder(ItemFinder):

    def find(self, matcher_stack):

        results = []
        for sectiondef in self.data_object.sectiondef:
            finder = self.item_finder_factory.create_finder(sectiondef)
            results.extend(finder.find(matcher_stack))

        return results

    def filter_(self, parent, filter_, matches):

        if filter_.allow(parent, self.data_object):
            matches.append(self.data_object)

        for sectiondef in self.data_object.sectiondef:
            finder = self.item_finder_factory.create_finder(sectiondef)
            finder.filter_(self.data_object, filter_, matches)

class SectionDefTypeSubItemFinder(ItemFinder):

    def find(self, matcher_stack):

        results = []
        for memberdef in self.data_object.memberdef:
            finder = self.item_finder_factory.create_finder(memberdef)
            results.extend(finder.find(matcher_stack))

        return results

    def filter_(self, parent, filter_, matches):

        for memberdef in self.data_object.memberdef:
            finder = self.item_finder_factory.create_finder(memberdef)
            finder.filter_(self.data_object, filter_, matches)

class MemberDefTypeSubItemFinder(ItemFinder):

    def find(self, matcher_stack):

        if matcher_stack.match("member", self.data_object):
            return [self.data_object]
        else:
            return []

    def filter_(self, parent, filter_, matches):

        pass
