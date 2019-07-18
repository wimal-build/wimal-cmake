function(me_check_name input _output)
    string(TOUPPER ${input} input)
    string(REGEX REPLACE [^A-Z|0-9] _ input ${input})
    set(${_output} ${input} PARENT_SCOPE)
endfunction(me_check_name)

function(me_compile_options)
    set(X_OPTIONS NO_CHECK NO_SET)
    set(X_SINGLES)
    set(X_MULTIS)
    cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

    include(CheckCCompilerFlag)
    foreach(flag ${X_UNPARSED_ARGUMENTS})
        me_check_name(${flag} name)
        check_c_compiler_flag(${flag} HAVE_${name})
        if(HAVE_${name})
            if(NOT X_NO_CHECK)
                set(HAVE_${name} ${HAVE_${name}} PARENT_SCOPE)
            endif()
            if(NOT X_NO_SET)
                add_compile_options(${flag})
            endif()
        endif()
    endforeach(flag)
endfunction()

function(me_checks)
    set(X_OPTIONS SET)
    set(X_SINGLES)
    set(X_MULTIS HEADERS FUNCS TYPES SIZES MEMBERS EXTRA_HEADERS)
    cmake_parse_arguments(X "${X_OPTIONS}" "${X_SINGLES}" "${X_MULTIS}" ${ARGN})

    include(CheckCSourceCompiles)
    include(CheckIncludeFile)
    include(CheckSymbolExists)
    include(CheckTypeSize)

    unset(X_INCLUDES)

    foreach(header ${X_HEADERS})
        me_check_name(HAVE_${header} name)
        check_include_file(${header} ${name})
        if (${name})
            set(${name} ${${name}} PARENT_SCOPE)
            list(APPEND X_INCLUDES ${header})
            if(X_SET)
                add_definitions(-D${name})
            endif()
        endif()
    endforeach(header)

    foreach(function ${X_FUNCS})
        me_check_name(HAVE_${function} name)
        check_symbol_exists(${function} "${X_INCLUDES};${X_EXTRA_HEADERS}" ${name})
        if(${name})
            set(${name} ${${name}} PARENT_SCOPE)
            if(X_SET)
                add_definitions(-D${name})
            endif()
        endif()
    endforeach(function)

    foreach(type ${X_TYPES})
        me_check_name(HAVE_${type} name)
        check_type_size(${type} ${name})
        if(${name})
            set(${name} ${${name}} PARENT_SCOPE)
            if(X_SET)
                add_definitions(-D${name})
            endif()
        endif()
    endforeach(type)

    foreach(type ${X_SIZES})
        me_check_name(SIZEOF_${type} name)
        check_type_size(${type} ${name})
        if(${name})
            set(${name} ${${name}} PARENT_SCOPE)
            if(X_SET)
                add_definitions(-D${name}=${${name}})
            endif()
        endif()
    endforeach(type)

    foreach(member ${X_MEMBERS})
        if(NOT member MATCHES "^([0-9|a-z|A-Z|_]+)\\.([0-9|a-z|A-Z|_]+)$")
            continue()
        endif()
        set(type ${CMAKE_MATCH_1})
        set(field ${CMAKE_MATCH_2})

        unset(includes)
        foreach(include ${X_INCLUDES} ${X_EXTRA_HEADERS})
            string(CONCAT includes "${includes}\n" "#include <${include}>\n")
        endforeach()
        me_check_name(HAVE_STRUCT_${type}_${field} name)
        check_c_source_compiles(
            "
                ${includes}
                int main() {
                    struct ${type} v;
                    (void) v.${field};
                }
            "
            ${name}
        )
        if(${name})
            set(${name} ${${name}} PARENT_SCOPE)
            if(X_SET)
                add_definitions(-D${name})
            endif()
        endif()
    endforeach(member)
endfunction(me_checks)

function(me_config_header src dst)
    file(READ ${src} content)
    string(
        REGEX REPLACE
        "# *undef HAVE_DECL" "#cmakedefine01 HAVE_DECL"
        content "${content}"
    )
    string(
        REGEX REPLACE
        "# *undef ([a-z|A-Z|0-9|_]+)" "#cmakedefine \\1 \@\\1\@"
        content "${content}"
    )
    file(WRITE ${dst}.cmake ${content})
    configure_file(${dst}.cmake ${dst} @ONLY)
endfunction(me_config_header)
