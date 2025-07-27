{-# LANGUAGE OverloadedStrings #-}

module LuaDSLCore where
import qualified Data.ByteString as B
import System.IO
import HsLua.Core
import Lua (luaopen_base, hslua_pushhsfunction, lua_setglobal)
import LuaDSLLogs
import Control.Concurrent (MVar, newEmptyMVar, readMVar, newMVar)
import LuaDSLFunctions
import qualified Data.String as B
import Test.WebDriver
import LuaDSLBrowserControl (luaTakeAndSaveScreenshot, luaLeftMouseClick, luaExecuteJavascriptCode)

data LuaTestContext = LuaTestContext {
    errorsList :: MVar [String],
    testName :: MVar String,
    wdActions :: MVar (WD())
} deriving (Eq)

data LuaTestResult = LuaTestResult {
    info :: [String],
    scriptFinishStatus :: Status,
    name :: String
} deriving (Show,Eq)


newEmptyContext :: IO LuaTestContext
newEmptyContext = do
    errors <- newMVar []
    name <- newMVar "Test"
    emptyWDActions <- newMVar $ openPage "https://ru.wikipedia.org/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0"
    return $ LuaTestContext errors name emptyWDActions


loadScript :: String -> IO String
loadScript = readFile



newLuaEnvironment :: LuaError e => LuaE e ()
newLuaEnvironment = do
    openbase
    newtable
    openmath
    openstring
    opentable


luaPrependFunctionToScript :: String -> String -> String
luaPrependFunctionToScript baseScript appending = appending ++ "\n" ++ baseScript



luaAddTestFunctionsToEnviroment :: LuaError e => LuaTestContext -> LuaE e() -> LuaE e ()
luaAddTestFunctionsToEnviroment context enviroment = do
    enviroment
    pushPreCFunction fact
    setglobal "fact"

    pushPreCFunction $ luaReportError $ errorsList context
    setglobal "reportError"

    pushPreCFunction $ luaNameTest $ testName context
    setglobal "setTestName"

    pushPreCFunction $ luaTakeAndSaveScreenshot $ wdActions context
    setglobal "takeAndSaveScreenshot"

    pushPreCFunction $ luaLeftMouseClick $ wdActions context
    setglobal "leftClick"

    pushPreCFunction $ luaExecuteJavascriptCode $ wdActions context
    setglobal "executeJS"

    

    
    

runLuaScriptWithContext :: LuaTestContext -> B.ByteString -> IO Status
runLuaScriptWithContext context script = run $ do
    (luaAddTestFunctionsToEnviroment context  newLuaEnvironment  :: LuaE Exception())
    dostring script


runLuaTest :: WDConfig -> String -> IO LuaTestResult
runLuaTest config path = do
    script <- loadScript path
    let embededScript = luaPrependFunctionToScript script luaPanicFunctionScript
    context <- newEmptyContext
    status <- runLuaScriptWithContext context $ B.fromString embededScript
    errors <- readMVar (errorsList context)
    name <- readMVar (testName context)
    wdAction <- readMVar (wdActions context)
    runSession config wdAction
    return $ LuaTestResult errors status name
