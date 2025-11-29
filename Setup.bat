@echo off
setlocal EnableDelayedExpansion

echo ==================================================
echo   BUILD DirectXTK from Git Submodule (VS2022)
echo ==================================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "SRC=%ROOT%\Vendors\directxtk"
set "DEST=%ROOT%\Libs\directxtk"

:: Checking submodule exists directxtk
if not exist "%SRC%" (
    echo [ERROR] Cannot find Vendors\directxtk
    echo         Running:
    echo         git submodule update --init --recursive
    pause
    exit /b 1
)

:: Check git submodule has been initialized
if not exist "%SRC%\CMakeLists.txt" (
    echo [INFO] Updating init submodule...
    git submodule update --init --recursive
)

:: Check CMake
where cmake >nul 2>&1 || (
    echo [ERROR] CMake is not have in PATH! Please install CMake then adds to PATH.
    pause
    exit /b 1
)

cd /d "%SRC%"

:: Create build temp folder
if exist "build_cmake" rmdir /S /Q "build_cmake"
mkdir build_cmake
cd build_cmake

echo [1/3] Configuring CMake (Visual Studio 2022 x64)...
cmake .. -G "Visual Studio 17 2022" -A x64 >nul
if %errorlevel% neq 0 (
    echo [ERROR] CMake configure failure!
    pause
    exit /b 1
)

echo [2/3] Building Release...
cmake --build . --config Release --parallel >nul
if %errorlevel% neq 0 ( echo [ERROR] Build Release Error! & pause & exit /b 1 )

echo [3/3] Building Debug...
cmake --build . --config Debug --parallel >nul
if %errorlevel% neq 0 ( echo [ERROR] Build Debug Error! & pause & exit /b 1 )

if not exist "%DEST%" mkdir "%DEST%"
if not exist "%DEST%\Include"      mkdir "%DEST%\Include"
if not exist "%DEST%\x64\Release"  mkdir "%DEST%\x64\Release"
if not exist "%DEST%\x64\Debug"    mkdir "%DEST%\x64\Debug"

:: Copy file
echo.
echo [COPY] Copying to Libs\directxtk...
xcopy /E /I /Y /Q "%SRC%\Inc"                "%DEST%\Include\"      >nul
copy /Y "lib\Release\DirectXTK.lib"             "%DEST%\x64\Release\"  >nul
copy /Y "lib\Debug\DirectXTK.lib"               "%DEST%\x64\Debug\"    >nul

:: Checking files have been copied
if exist "%DEST%\x64\Release\DirectXTK.lib" (
    echo [OK] Release lib copied
) else (
    echo [ERROR] Can't find Release lib! Please check build folder.
    pause
    exit /b 1
)

if exist "%DEST%\x64\Debug\DirectXTK.lib" (
    echo [OK] Debug lib copied
) else (
    echo [WARNING] Can't find Debug lib! Please check build folder
)

:: Cleaning
echo.
echo -> Cleaning temp build folder...
if exist "%SRC%\build_cmake" (
    rmdir /S /Q "%SRC%\build_cmake" >nul 2>&1
    if exist "%SRC%\build_cmake" (
        rmdir /S /Q "%SRC%\build_c" >nul 2>&1
    )
)

cd /d "%ROOT%" >nul 2>&1

echo.
echo Completed 100%!
echo.
echo DirectXTK is ready:
echo   Include: Libs\directxtk\Include
echo   Lib Release: Libs\directxtk\x64\Release\DirectXTK.lib
echo   Lib Debug: Libs\directxtk\x64\Debug\DirectXTK.lib
echo.
echo Press any key to exit...
pause