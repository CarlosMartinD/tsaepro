@echo off
rem Parameters:
rem %1: listening port for TestServer
rem %2: numHosts
rem optional args:
rem -h <IP address of TestServer>: IP Address of TestServer
rem --nopurge: deactivates purge
rem -pResults <percentageRequiredResults>: percentage of received results prior to perform evaluation (e.g. 50 means 50%, 75 means 75%)
rem --remoteMode: Server will run in different computers (or more than one Server in a single computer but this computer having the same internal and external IP address)
rem --localMode: (default running mode. If no mode is specified it will suppose local mode) all Serves will run in the same computers
rem --menu: run in menu mode
rem --logResults: appends the result of the each execution to a file named as the groupId
rem -path <path>: path to directory where store results (if --logResults is activated)
rem --remoteTestServer: indicates that the TestServer runs in a different computer that Servers
rem --noremove: deactivates the generation by simulation of operations that remove recipes

rem killall java

timeout /t 1 >nul

set LOCAL_TEST_SERVER="true"
set PHASE1="false"
for %%i in (%*)
do
    if "%%i"=="--remoteTestServer" (
        set LOCAL_TEST_SERVER="false"
    )
    if "%%i"=="--phase1" (
        set PHASE1="true"
    )
done

if %PHASE1%=="true" (
    rem phase 1
    java -cp ../bin;../lib/* recipes_service.test.Phase1TestServer %* ^
    timeout /t 1 >nul
    java -cp ../bin;../lib/* recipes_service.Phase1 %*
) else (
    rem phase 2 to 4
    if %LOCAL_TEST_SERVER%=="true" (
        java -cp ../bin;../lib/* recipes_service.test.TestServer %* ^
        timeout /t 1 >nul
    )

    timeout /t 1 >nul

    java -cp ../bin;../lib/* recipes_service.test.SendArgsToTestServer %*

    timeout /t 3 >nul

    for /L %%i in (0,1,%2) do (
        set FILE="f_%%i"
        if %2 leq 4 (
            rem runs each java process in a different terminal emulator window
            start java -cp ../bin;../lib/* recipes_service.Server %* ^> %FILE%
        ) else (
            rem runs all java processes in the same terminal emulator window
            java -cp ../bin;../lib/* recipes_service.Server %* ^> %FILE%
        )
    )
)

pause
