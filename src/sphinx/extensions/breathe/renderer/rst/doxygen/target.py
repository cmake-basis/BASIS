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

class TargetHandler(object):

    def __init__(self, project_info, node_factory, document):

        self.project_info = project_info
        self.node_factory = node_factory
        self.document = document

    def create_target(self, refid):

        target = self.node_factory.target(refid=refid, ids=[refid], names=[refid])

        # Tell the document about our target
        try:
            self.document.note_explicit_target(target)
        except Exception, e:
            print "Failed to register id: %s. This is a seemingly harmless bug." % refid

        return [target]

class NullTargetHandler(object):

    def create_target(self, refid):
        return []


class TargetHandlerFactory(object):

    def __init__(self, node_factory):

        self.node_factory = node_factory

    def create(self, options, project_info, document):

        if options.has_key("no-link"):
            return NullTargetHandler()

        return TargetHandler(project_info, self.node_factory, document)

