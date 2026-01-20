# cmake/BasiliskTargets.cmake


# For use building targets outside the source tree

function(add_basilisk_executable target_name source)

  set(CMAKE_VERBOSE_MAKEFILE ON)

  # 1) parse named args: GRID (single) and INCLUDE_DIRS (multiple)
  set(options)
  set(oneValueArgs GRID)
  set(multiValueArgs INCLUDE_DIRS)
  cmake_parse_arguments(BE "" "GRID" "INCLUDE_DIRS" ${ARGN})

  # default GRID to "none" if the caller didn’t specify it
  if(NOT BE_GRID)
    set(qcc_grid_flag "")
  else()
    if (BE_GRID STREQUAL "")
      set(qcc_grid_flag "")
    else()
    set(qcc_grid_flag "-grid=${BE_GRID}")
      endif()
  endif()

  # 2) turn INCLUDE_DIRS into both -I flags for the qcc invocation
  #    and into a list we’ll give to the real CMake target
  set(qcc_include_flags)
  foreach(inc IN LISTS BE_INCLUDE_DIRS)
    list(APPEND qcc_include_flags "-I${inc}")
  endforeach()

  # Absolute path
  get_filename_component(absolute_source "${source}" ABSOLUTE)

  # Filename e.g. file.c -> file
  get_filename_component(filename "${source}" NAME_WE)

  # Path of source relative to CMAKE_SOURCE_DIR e.g. 
  # /home/user/.../myproject/src/ex.c -> /myproject/src/ex.c
  file(RELATIVE_PATH relative_path "${CMAKE_SOURCE_DIR}" "${absolute_source}")

  # Relative path parent directory e.g. /myproject/src/ex.c -> /myproject/src
  get_filename_component(relative_directory "${relative_path}" DIRECTORY)

  set(build_source_directory "${CMAKE_BINARY_DIR}/${relative_directory}")
  set(input_copy "${build_source_directory}/${filename}.c")
  set(generated_c "${build_source_directory}/_${filename}.c")

  # cmd to produce the example
  add_custom_command(
    OUTPUT "${target_name}.c"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${absolute_source}" "${input_copy}"
    WORKING_DIRECTORY "${build_source_directory}"
    COMMAND $<TARGET_FILE:qcc-source> "${filename}.c" -o "_${filename}.c" -source ${qcc_include_flags}
    COMMAND ${CMAKE_COMMAND} -E rename "_${filename}.c" "${target_name}.c"
    COMMAND ${CMAKE_COMMAND} -E remove "${input_copy}"
    DEPENDS
      "${absolute_source}"
      qcc-source
  )

  add_executable(${target_name} "${target_name}.c")
  set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${build_source_directory}")
  target_compile_options(${target_name} PRIVATE -Wall -D_FORTIFY_SOURCE=2)

  if (BE_INCLUDE_DIRS)
    target_include_directories(${target_name} PRIVATE ${BE_INCLUDE_DIRS})
  endif()
  
endfunction()


# For use building targets inside the source tree

function(add_basilisk_source_executable target_name source)

  # 1) parse named args: GRID (single) and INCLUDE_DIRS (multiple)
  set(options)
  set(oneValueArgs GRID)
  set(multiValueArgs INCLUDE_DIRS)
  cmake_parse_arguments(BE "" "GRID" "INCLUDE_DIRS" ${ARGN})

  # default GRID to "none" if the caller didn’t specify it
  if(NOT BE_GRID)
    set(qcc_grid_flag "")
  else()
    if (BE_GRID STREQUAL "")
      set(qcc_grid_flag "")
    else()
    set(qcc_grid_flag "-grid=${BE_GRID}")
      endif()
  endif()


  # 2) turn INCLUDE_DIRS into both -I flags for the qcc invocation
  #    and into a list we’ll give to the real CMake target
  set(qcc_include_flags)
  foreach(inc IN LISTS BE_INCLUDE_DIRS)
    list(APPEND qcc_include_flags "-I${inc}")
  endforeach()

  # Absolute path
  get_filename_component(absolute_source "${source}" ABSOLUTE)

  # Filename e.g. file.c -> file
  get_filename_component(filename "${source}" NAME_WE)

  # Path of source relative to CMAKE_SOURCE_DIR e.g. 
  # /home/user/.../myproject/src/ex.c -> /myproject/src/ex.c
  file(RELATIVE_PATH relative_path "${CMAKE_SOURCE_DIR}" "${absolute_source}")

  # Relative path parent directory e.g. /myproject/src/ex.c -> /myproject/src
  get_filename_component(relative_directory "${relative_path}" DIRECTORY)

  set(build_source_directory "${CMAKE_BINARY_DIR}/${relative_directory}")
  set(input_copy "${build_source_directory}/${filename}.c")
  set(generated_c "${build_source_directory}/_${filename}.c")

  # cmd to produce the example
  add_custom_command(
    OUTPUT "${target_name}.c"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${absolute_source}" "${input_copy}"
    WORKING_DIRECTORY "${build_source_directory}"
    COMMAND $<TARGET_FILE:qcc-source> "${filename}.c" -o "_${filename}.c" -source ${qcc_grid_flag} ${qcc_include_flags} -I
    COMMAND ${CMAKE_COMMAND} -E rename "_${filename}.c" "${target_name}.c"
    COMMAND ${CMAKE_COMMAND} -E remove "${input_copy}"
    DEPENDS
      "${absolute_source}"
      qcc-source
  )

  add_executable(${target_name} "${target_name}.c")
  set_target_properties(${target_name} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${build_source_directory}")
  target_compile_options(${target_name} PRIVATE -Wall -D_FORTIFY_SOURCE=2)

  if (BE_INCLUDE_DIRS)
    target_include_directories(${target_name} PRIVATE ${BE_INCLUDE_DIRS})
  endif()
  
endfunction()


