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

data LuaTestContext = LuaTestContext {
    errorsList :: MVar [String],
    testName :: MVar String
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
    return $ LuaTestContext errors name


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

    

runLuaScriptWithContext :: LuaTestContext -> B.ByteString -> IO Status
runLuaScriptWithContext context script = run $ do
    (luaAddTestFunctionsToEnviroment context  newLuaEnvironment  :: LuaE Exception())
    dostring script


runLuaTest :: String -> IO LuaTestResult
runLuaTest path = do
    script <- loadScript path
    let embededScript = luaPrependFunctionToScript script luaPanicFunctionScript
    context <- newEmptyContext
    status <- runLuaScriptWithContext context $ B.fromString embededScript
    errors <- readMVar (errorsList context)
    name <- readMVar (testName context)
    return $ LuaTestResult errors status name
