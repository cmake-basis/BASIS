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

        compounds = self.data_object.get_compound()

        results = []

        for compound in compounds:

            if matcher_stack.match("compound", compound):
                compound_finder = self.item_finder_factory.create_finder(compound)
                results.extend(compound_finder.find(matcher_stack))

        return results


    def filter_(self, filter_, matches):

        compounds = self.data_object.get_compound()

        for compound in compounds:
            compound_finder = self.item_finder_factory.create_finder(compound)
            compound_finder.filter_(self.data_object, filter_, matches)

class CompoundTypeSubItemFinder(ItemFinder):

    def __init__(self, matcher_factory, compound_parser, *args):
        ItemFinder.__init__(self, *args)

        self.matcher_factory = matcher_factory
        self.compound_parser = compound_parser

    def find(self, matcher_stack):

        members = self.data_object.get_member()

        member_results = []

        for member in members:
            if matcher_stack.match("member", member):
                member_finder = self.item_finder_factory.create_finder(member)
                member_results.extend(member_finder.find(matcher_stack))

        results = []

        # If there are members in this compound that match the criteria 
        # then load up the file for this compound and get the member data objects
        if member_results:

            file_data = self.compound_parser.parse(self.data_object.refid)
            finder = self.item_finder_factory.create_finder(file_data)

            for member_data in member_results:
                ref_matcher_stack = self.matcher_factory.create_ref_matcher_stack("", member_data.refid)
                # TODO: Fix this! Should be ref_matcher_stack!
                results.extend(finder.find(matcher_stack))

        elif matcher_stack.full_match("compound", self.data_object):
            results.append(self.data_object)

        return results


    def filter_(self, parent, filter_, matches):

        file_data = self.compound_parser.parse(self.data_object.refid)
        finder = self.item_finder_factory.create_finder(file_data)

        finder.filter_(self.data_object, filter_, matches)

class MemberTypeSubItemFinder(ItemFinder):

    def find(self, matcher_stack):

        if matcher_stack.full_match("member", self.data_object):
            return [self.data_object]
        else:
            return []


