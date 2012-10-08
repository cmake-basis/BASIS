Whenever a template file is modified or removed, the previous project template
has to be copied to a new directory with an updated template version!
Otherwise, the three-way diff merge used by the basisproject tool to update
existing projects to this newer template will fail. Also do not forget to
add an installation rule for the new template to the CMakeLists.txt file and
set the TEMPLATE_VERSION variable in the root CMakeLists.txt file of BASIS
to the new template version.

Note: Only the files which were modified or added have to be present in the
      new template. The basisproject tool will look in older template
      directories for any missing files.
