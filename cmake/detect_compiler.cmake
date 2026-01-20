# -------------------------------------------------------------------
# A little helper that “detects” the C compiler and hands back
#   – its ID   (GNU, Clang, Intel, MSVC, …)
#   – its version
#   – the full path to the compiler executable
# Usage:
#   detect_c_compiler(COMP)                # returns COMP_ID, COMP_VERSION, COMP_PATH
# -------------------------------------------------------------------
function(detect_c_compiler OUTPUT_PREFIX)
  if(NOT DEFINED CMAKE_C_COMPILER_ID)
    message(FATAL_ERROR "C compiler not set (CMAKE_C_COMPILER_ID is undefined)!")
  endif()

  # Set three variables in the parent scope:
  set("${OUTPUT_PREFIX}_ID"      "${CMAKE_C_COMPILER_ID}"      PARENT_SCOPE)
  set("${OUTPUT_PREFIX}_VERSION" "${CMAKE_C_COMPILER_VERSION}" PARENT_SCOPE)
  set("${OUTPUT_PREFIX}_PATH"    "${CMAKE_C_COMPILER}"         PARENT_SCOPE)
endfunction()
