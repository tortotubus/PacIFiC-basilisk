# cmake/generate_symbols.cmake
#
# Usage (from your CMakeLists.txt):
#   cmake -DBASILISK_C=/path/to/basilisk.c \
#         -DOUT=/path/to/symbols.h \
#     -P generate_symbols.cmake

if(NOT DEFINED BASILISK_C OR NOT DEFINED OUT)
  message(FATAL_ERROR
    "Usage: cmake -DBASILISK_C=<path-to-basilisk.c> "
    "-DOUT=<output-symbols.h> -P generate_symbols.cmake")
endif()

# 1) Write the three header lines exactly as in your Makefile:
file(WRITE "${OUT}"
  "// Automatically generated from basilisk.yacc\n"
)
file(APPEND "${OUT}"
  "const char * symbol_name (int sym);\n"
)
file(APPEND "${OUT}"
  "int token_symbol (int token);\n\n"
)

# 2) Read basilisk.c line by line
file(STRINGS "${BASILISK_C}" _lines)

set(in_enum FALSE)
foreach(line IN LISTS _lines)
  # Start printing once we hit the enum declaration
  if(NOT in_enum AND line MATCHES "^enum[ ]+yysymbol_kind_t")
    set(in_enum TRUE)
  endif()

  if(in_enum)
    # Apply the sed-style replacement YYSYMBOL_ → sym_
    string(REPLACE "YYSYMBOL_" "sym_" processed "${line}")
    file(APPEND "${OUT}" "${processed}\n")

    # Stop immediately after the line containing “};”
    if(processed MATCHES "};")
      break()
    endif()
  endif()
endforeach()

if(NOT in_enum)
  message(FATAL_ERROR
    "Couldn’t find enum yysymbol_kind_t … closing '};' in ${BASILISK_C}")
endif()
