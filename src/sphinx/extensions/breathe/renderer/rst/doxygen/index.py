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

from breathe.renderer.rst.doxygen.base import Renderer

class DoxygenTypeSubRenderer(Renderer):

    def render(self):

        nodelist = []

        # Process all the compound children
        for compound in self.data_object.get_compound():
            compound_renderer = self.renderer_factory.create_renderer(self.data_object, compound)
            nodelist.extend(compound_renderer.render())

        return nodelist


class CompoundTypeSubRenderer(Renderer):

    def __init__(self, compound_parser, *args):
        Renderer.__init__(self, *args)

        self.compound_parser = compound_parser

    def create_target(self, refid):

        return self.target_handler.create_target(refid)

    def create_domain_id(self):

        return ""

    def render(self):

        refid = "%s%s" % (self.project_info.name(), self.data_object.refid)
        nodelist = self.create_target(refid)

        domain_id = self.create_domain_id()


        # Read in the corresponding xml file and process
        file_data = self.compound_parser.parse(self.data_object.refid)

        lines = []

        # Check if there is template information and format it as desired
        if file_data.compounddef.templateparamlist:
            renderer = self.renderer_factory.create_renderer(
                    file_data.compounddef,
                    file_data.compounddef.templateparamlist
                    )
            template = [
                    self.node_factory.Text("template < ")
                ]
            template.extend(renderer.render())
            template.append(self.node_factory.Text(" >"))
            lines.append(self.node_factory.line("", *template))

        # Set up the title and a reference for it (refid)
        kind = self.node_factory.emphasis(text=self.data_object.kind)
        name = self.node_factory.strong(text=self.data_object.name)

        # Add blank string at the start otherwise for some reason it renders
        # the emphasis tags around the kind in plain text
        lines.append(
                self.node_factory.line(
                    "", 
                    self.node_factory.Text(""),
                    kind,
                    self.node_factory.Text(" "),
                    name
                    )
                )


        if file_data.compounddef.includes:
            for include in file_data.compounddef.includes:
                renderer = self.renderer_factory.create_renderer(
                        file_data.compounddef,
                        include
                        )
                result = renderer.render()
                if result:
                    lines.append(
                            self.node_factory.line(
                                "",
                                self.node_factory.Text(""),
                                *result
                                )
                            )

        nodelist.append(
                self.node_factory.line_block(
                    "",
                    *lines
                    )
                )

        data_renderer = self.renderer_factory.create_renderer(self.data_object, file_data)
        nodelist.extend(data_renderer.render())

        return nodelist


class ClassCompoundTypeSubRenderer(CompoundTypeSubRenderer):

    def create_target(self, refid):

        self.domain_handler.create_class_target(self.data_object)
        return CompoundTypeSubRenderer.create_target(self, refid)

    def create_domain_id(self):

        return self.domain_handler.create_class_id(self.data_object)

