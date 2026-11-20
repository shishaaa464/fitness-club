cmake_minimum_required(VERSION 3.16)

project(FitnessClubApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(appFitnessClubApp
    main.cpp
    clientlistmodel.h clientlistmodel.cpp
    datamanager.h datamanager.cpp
    membership.h membership.cpp
    notificationmanager.h notificationmanager.cpp
    pricingstrategy.h pricingstrategy.cpp
    reportmanager.h reportmanager.cpp
    user.h user.cpp
    visit.h visit.cpp
    visitmodel.h visitmodel.cpp
    observer.h
)

# 2. Подключаем модуль QML и прописываем ВСЕ QML файлы интерфейса
qt_add_qml_module(appFitnessClubApp
    URI FitnessClubApp
    VERSION 1.0
    QML_FILES
        Main.qml
        AdminDashboard.qml
        ClientProfile.qml
        LoginScreen.qml
)

set_target_properties(appFitnessClubApp PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Линкуем библиотеку Qt6 Quick
target_link_libraries(appFitnessClubApp
    PRIVATE Qt6::Quick
)

install(TARGETS appFitnessClubApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)