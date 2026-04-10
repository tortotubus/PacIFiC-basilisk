add_library(tinyrenderer STATIC
  tiny.c
)

target_include_directories(tinyrenderer
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
    $<INSTALL_INTERFACE:include/basilisk/gl/tinyrenderer>
    $<INSTALL_INTERFACE:include/basilisk/gl>
)

target_link_libraries(tinyrenderer PUBLIC m)
