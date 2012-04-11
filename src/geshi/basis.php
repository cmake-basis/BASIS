<?php
/**
 * @file basis.php
 * @brief BASIS/CMake language file for GeSHi.
 *
 * @note Based on cmake.php file of GeSHi release version 1.0.8.10.
 *
 * Copyright (c) 2011 University of Pennsylvania. All rights reserved.<br />
 * See http://www.rad.upenn.edu/sbia/software/license.html or COPYING file.
 *
 * Contact: SBIA Group <sbia-software at uphs.upenn.edu>
 */

$language_data = array (
    'LANG_NAME' => 'BASIS',
    'COMMENT_SINGLE' => array(1 => '#'),
    'COMMENT_MULTI' => array(),
    'CASE_KEYWORDS' => GESHI_CAPS_NO_CHANGE,
    'QUOTEMARKS' => array('"'),
    'ESCAPE_CHAR' => '\\',
    'ESCAPE_REGEXP' => array(
        // Quoted variables ${...}
        1 => "/\\$(ENV)?\\{[^\\n\\}]*?\\}/i",
        // Quoted registry keys [...]
        2 => "/\\[HKEY[^\n\\]]*?]/i"
        ),
    'KEYWORDS' => array(
        // BASIS commands
        1 => array(
            'basis_find_package',
            'basis_add_executable',
            'basis_add_library',
            'basis_target_link_libraries',
            'basis_add_definitions',
            'basis_add_test',
            'basis_get_target_property',
            'basis_set_target_properties',
            'basis_target_link_libraries',
            'basis_install'
            ),
        // CMake commands
        2 => array(
            'add_custom_command',
            'add_custom_target',
            'add_dependencies',
            'add_subdirectory',
            'aux_source_directory',
            'break',
            'build_command',
            'cmake_minimum_required',
            'cmake_policy',
            'configure_file',
            'create_test_sourcelist',
            'define_property',
            'else',
            'elseif',
            'enable_language',
            'enable_testing',
            'endforeach',
            'endfunction',
            'endif',
            'endmacro',
            'endwhile',
            'execute_process',
            'export',
            'file',
            'find_file',
            'find_library',
            'find_path',
            'find_program',
            'fltk_wrap_ui',
            'foreach',
            'function',
            'get_cmake_property',
            'get_directory_property',
            'get_property',
            'get_source_file_property',
            'get_test_property',
            'if',
            'include',
            'include_external_msproject',
            'include_regular_expression',
            'list',
            'load_cache',
            'load_command',
            'macro',
            'mark_as_advanced',
            'math',
            'message',
            'option',
            'output_required_files',
            'project',
            'qt_wrap_cpp',
            'qt_wrap_ui',
            'remove_definitions',
            'return',
            'separate_arguments',
            'set',
            'set_directory_properties',
            'set_property',
            'set_source_files_properties',
            'set_tests_properties',
            'site_name',
            'source_group',
            'string',
            'try_compile',
            'try_run',
            'unset',
            'variable_watch',
            'while'
            ),
        // overwritten CMake commands
        3 => array(
            'add_executable', 'add_library', 'add_definitions', 'add_test',
            'find_package', 'get_filename_component', 'include_directories',
            'link_directories'
            ),
        // deprecated CMake commands
        4 => array(
            'build_name',
            'exec_program',
            'export_library_dependencies',
            'install_files',
            'install_programs',
            'install_targets',
            'link_libraries',
            'make_directory',
            'remove',
            'subdir_depends',
            'subdirs',
            'use_mangled_mesa',
            'utility_source',
            'variable_requires',
            'write_file',
            'get_target_property',
            'set_target_properties',
            'install',
            'target_link_libraries'
            ),
        // special command arguments (BASIS)
        5 => array(
            'LIBEXEC',
            'TEST',
            'WITH_EXT',
            'WITH_PATH',
            'NO_BASIS_UTILITIES',
            'NO_EXPORT',
            'MEX',
            'LANGUAGE',
            'DESTINATION',
            'RUNTIME_DESTINATION',
            'LIBRARY_DESTINATION',
            'COMPONENT',
            'RUNTIME_COMPONENT',
            'LIBRARY_COMPONENT',
            'CONFIG',
            'CONFIG_FILE'
            ),
        // special command arguments (CMake)
        6 => array(
            'AFTER', 'AND', 'APPEND', 'ASCII',
            'BEFORE', 'BOOL', 'CACHE', 'COMMAND', 'COMMENT',
            'COMPARE', 'CONFIGURE', 'DEFINED', 'DEPENDS', 'DIRECTORY',
            'EQUAL', 'EXCLUDE_FROM_ALL', 'EXISTS', 'FALSE', 'FATAL_ERROR',
            'FILEPATH', 'FIND', 'FORCE', 'GET', 'GLOBAL', 'GREATER',
            'IMPLICIT_DEPENDS', 'INSERT', 'INTERNAL', 'IS_ABSOLUTE',
            'IS_DIRECTORY', 'IS_NEWER_THAN', 'LENGTH', 'LESS',
            'MAIN_DEPENDENCY', 'MATCH', 'MATCHALL', 'MATCHES', 'MODULE', 'NOT',
            'NOTFOUND', 'OFF', 'ON', 'OR', 'OUTPUT', 'PARENT_SCOPE', 'PATH',
            'POLICY', 'POST_BUILD', 'PRE_BUILD', 'PRE_LINK', 'PROPERTY',
            'RANDOM', 'REGEX', 'REMOVE_AT', 'REMOVE_DUPLICATES', 'REMOVE_ITEM',
            'REPLACE', 'REVERSE', 'SEND_ERROR', 'SHARED', 'SORT', 'SOURCE',
            'STATIC', 'STATUS', 'STREQUAL', 'STRGREATER', 'STRING', 'STRIP',
            'STRLESS', 'SUBSTRING', 'SYSTEM', 'TARGET', 'TEST', 'TOLOWER', 'TOUPPER',
            'TRUE', 'VERBATIM', 'VERSION', 'VERSION_EQUAL', 'VERSION_GREATOR',
            'VERSION_LESS', 'WORKING_DIRECTORY'
            )
        ),
    'CASE_SENSITIVE' => array(
        GESHI_COMMENTS => false,
        1 => false,
        2 => false,
        3 => false,
        4 => false,
        5 => true,
        6 => true
        ),
    'SYMBOLS' => array(
        0 => array('(', ')')
        ),
    'STYLES' => array(
        'KEYWORDS' => array(
            1 => 'color: #1f3f81; font-style: bold;',
            2 => 'color: #1f3f81; font-style: bold;',
            3 => 'color: #1f3f81;',
            4 => 'color: #1f3f81;',
            5 => 'color: #077807; font-sytle: italic;',
            6 => 'color: #077807; font-sytle: italic;'
            ),
        'BRACKETS' => array(),
        'COMMENTS' => array(
            1 => 'color: #666666; font-style: italic;'
            ),
        'ESCAPE_CHAR' => array(
            0 => 'color: #000099; font-weight: bold;',
            1 => 'color: #b08000;',
            2 => 'color: #0000cd;'
            ),
        'STRINGS' => array(
            0 => 'color: #912f11;',
            ),
        'SYMBOLS' => array(
            0 => 'color: #197d8b;'
            ),
        'NUMBERS' => array(),
        'METHODS' => array(),
        'REGEXPS' => array(
            0 => 'color: #b08000;',
            1 => 'color: #0000cd;'
            ),
        'SCRIPT' => array()
        ),
    'URLS' => array(
        1 => '',
        2 => 'http://www.cmake.org/cmake/help/cmake2.8docs.html#command:{FNAMEL}',
        3 => 'http://www.cmake.org/cmake/help/cmake2.8docs.html#command:{FNAMEL}',
        4 => 'http://www.cmake.org/cmake/help/cmake2.8docs.html#command:{FNAMEL}',
        5 => '',
        6 => ''
        ),
    'OOLANG' => false,
    'OBJECT_SPLITTERS' => array(),
    'REGEXPS' => array(
        // Unquoted variables
        0 => "\\$(ENV)?\\{[^\\n}]*?\\}",
        // Unquoted registry keys
        1 => "\\[HKEY[^\n\\]]*?]"
        ),
    'STRICT_MODE_APPLIES' => GESHI_NEVER,
    'SCRIPT_DELIMITERS' => array(),
    'HIGHLIGHT_STRICT_BLOCK' => array(),
    'TAB_WIDTH' => 4,
    'PARSER_CONTROL' => array(
        'KEYWORDS' => array(
            // These keywords cannot come after a open paren
            1 => array(
                'DISALLOWED_AFTER' =>  '(?= *\()'
                ),
            2 => array(
                'DISALLOWED_AFTER' =>  '(?= *\()'
                ),
            3 => array(
                'DISALLOWED_AFTER' =>  '(?= *\()'
                ),
            4 => array(
                'DISALLOWED_AFTER' =>  '(?= *\()'
                )
            ),
        'ENABLE_FLAGS' => array(
            'BRACKETS' => GESHI_NEVER,
            'METHODS' => GESHI_NEVER,
            'NUMBERS' => GESHI_NEVER
            )
        )
);

?>
