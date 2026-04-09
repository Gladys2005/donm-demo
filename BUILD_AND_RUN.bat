@echo off
echo ====================================
echo    BUILD ET RUN DONM APP
echo ====================================
echo.

cd /d "C:\Users\DELL\OneDrive - IPNET INSTITUTE OF TECHNOLOGY\Bureau\STAGE\gladys\donm"

echo.
echo [1/3] Nettoyage des anciens builds...
if exist build\web (
    rmdir /s /q build\web
    echo    - Anciens builds supprimes
)

echo.
echo [2/3] Build Flutter en mode release...
flutter build web --release --web-renderer canvaskit --no-sound-null-safety

if %ERRORLEVEL% NEQ 0 (
    echo    - ERREUR: Le build a echoue
    pause
    exit /b 1
)

echo.
echo [3/3] Demarrage du serveur local...
echo.
echo Lien: http://localhost:8080
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

cd build\web
python -m http.server 8080

pause
