cmake_minimum_required(VERSION 3.21)

project(Chapter1_Vector_Algebra)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE
        Common
)

if (MSVC)
    target_link_options(${PROJECT_NAME}
            PRIVATE
            /SUBSYSTEM:CONSOLE
    )
endif ()