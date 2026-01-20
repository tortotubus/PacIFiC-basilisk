foreach(var CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_RELWITHDEBINFO CMAKE_C_FLAGS_MINSIZEREL)
  if(DEFINED ${var})
    string(REGEX REPLACE "(^|[ \t])-DNDEBUG([ \t]|$)" " " ${var} "${${var}}")
    string(STRIP "${${var}}" ${var})
  endif()
endforeach()

# --- grammar --------------------------------------------------------

add_executable(qcc-grammar ast/grammar.c)

# Fix for redhat based systems where the default is to build a PIE
# executable, which we do not want for this utility.
target_compile_options(qcc-grammar PRIVATE -fno-PIE)
target_link_options(qcc-grammar PRIVATE -no-pie)

# --- generated grammar.h --------------------------------------------

set(YACC_IN   "${CMAKE_CURRENT_SOURCE_DIR}/ast/basilisk.yacc")
set(YACC_OUT  "${CMAKE_CURRENT_BINARY_DIR}/ast/grammar.h")

add_custom_command(
  OUTPUT "${YACC_OUT}"
  # Ensure the output directory exists (first build / clean build)
  COMMAND "${CMAKE_COMMAND}" -E make_directory
          "${CMAKE_CURRENT_BINARY_DIR}/ast"
  # Run the *built* grammar tool (not whatever is on PATH)
  COMMAND $<TARGET_FILE:qcc-grammar> < "${YACC_IN}" > "${YACC_OUT}"
  DEPENDS qcc-grammar "${YACC_IN}"
  # BYPRODUCTS "${YACC_OUT}"
  COMMENT "Generating grammar.h from basilisk.yacc"
  VERBATIM
)

# Phony target to make ordering explicit and easy to debug
add_custom_target(qcc-grammar-utility DEPENDS "${YACC_OUT}")

# --- qcc-install --------------------------------------------------

add_executable(qcc-install
  qcc.c
  include.c
  postproc.c
  ast/ast.c
  ast/tokens.c
  ast/basilisk.c
  ast/translate.c
  ast/allocator.c
  ast/faststack.c
  ast/stencil.c
  ast/types.c
  ast/references.c
  ast/kernels.c
  ast/check.c
  ast/interpreter/interpreter.c
  "${YACC_OUT}"   # keep listed so the file-level graph is correct
)

# Make sure qcc waits for grammar.h generation
add_dependencies(qcc-install qcc-grammar)

# Tell CMake this header is generated (helps IDEs and some generators)
set_source_files_properties("${YACC_OUT}" PROPERTIES GENERATED TRUE)

add_executable(Basilisk::qcc-install ALIAS qcc-install)

target_include_directories(qcc-install PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/ast"
  "${CMAKE_CURRENT_BINARY_DIR}/ast"   # where grammar.h is generated
  "${CMAKE_CURRENT_SOURCE_DIR}/ast/interpreter"
)

target_compile_definitions(qcc-install PRIVATE
  LIBDIR=\"${LIBDIR}\"
  CC99=\"${CC99}\"
  CPP99=\"${CPP99}\"
  CADNACC=\"${CADNACC}\"
  BASILISK=\"${BASILISK}\"
)

message(STATUS "qcc-install using ${BASILISK}")

target_link_libraries(qcc-install PRIVATE m)

# --- qcc-toolchain --------------------------------------------------

add_executable(qcc-toolchain
  qcc.c
  include.c
  postproc.c
  ast/ast.c
  ast/tokens.c
  ast/basilisk.c
  ast/translate.c
  ast/allocator.c
  ast/faststack.c
  ast/stencil.c
  ast/types.c
  ast/references.c
  ast/kernels.c
  ast/check.c
  ast/interpreter/interpreter.c
  "${YACC_OUT}"   # keep listed so the file-level graph is correct
)

# Make sure qcc waits for grammar.h generation
add_dependencies(qcc-toolchain qcc-grammar)

# Tell CMake this header is generated (helps IDEs and some generators)
set_source_files_properties("${YACC_OUT}" PROPERTIES GENERATED TRUE)

add_executable(Basilisk::qcc-toolchain ALIAS qcc-toolchain)

target_include_directories(qcc-toolchain PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/ast"
  "${CMAKE_CURRENT_BINARY_DIR}/ast"   # where grammar.h is generated
  "${CMAKE_CURRENT_SOURCE_DIR}/ast/interpreter"
)

target_compile_definitions(qcc-toolchain PRIVATE
  LIBDIR=\"${LIBDIR_SOURCE}\"
  CC99=\"${CC99}\"
  CPP99=\"${CPP99}\"
  CADNACC=\"${CADNACC}\"
  BASILISK=\"${BASILISK_SOURCE}\"
)

target_compile_options(qcc-toolchain PRIVATE
  $<$<COMPILE_LANGUAGE:C>:-O0>
  $<$<COMPILE_LANGUAGE:CXX>:-O0>
)

message(STATUS "qcc-toolchain using ${BASILISK_SOURCE}")

target_link_libraries(qcc-toolchain PRIVATE m)