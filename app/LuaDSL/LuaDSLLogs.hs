{-# LANGUAGE OverloadedStrings #-}

module LuaDSLLogs where
import HsLua (LuaError, setfield, setglobal, HaskellFunction, PreCFunction, tointeger, nthTop, NumResults (NumResults))
import HsLua.Core (pushHaskellFunction, nthTop, LuaE,newtable,fromName, Name)
import HsLua.Core.Types (liftIO, fromLuaBool)
import Control.Exception (Exception)
import Foreign (Storable(peek), nullPtr)
import Lua (lua_tointegerx, lua_pop, lua_pushinteger, lua_tolstring, lua_isstring)
import Foreign.C (CInt(CInt), peekCString)
import Data.Maybe (mapMaybe, isJust, fromJust)
import Text.ParserCombinators.ReadPrec (Prec)
import System.IO (hPutStrLn, stderr)
import Control.Concurrent.MVar

fact :: PreCFunction
fact luaState = do
    n <- Lua.lua_tointegerx luaState 1 nullPtr
    let result = hsfact (fromIntegral n)
    lua_pop luaState 1
    lua_pushinteger luaState (fromIntegral result)
    return (NumResults 1)


luaNameTest :: MVar String -> PreCFunction
luaNameTest nameMVar luaState = do
    isString <- lua_isstring luaState 1

    if fromLuaBool isString
      then do
        cstr <- lua_tolstring luaState 1 nullPtr
        msg <- if cstr /= nullPtr
               then peekCString cstr
               else return "Unknown error"
        
        liftIO $ modifyMVar_ nameMVar $ \_ -> return msg
      else
        liftIO $ modifyMVar_ nameMVar $ \_ -> return "Test"
    
    lua_pop luaState 1
    return (NumResults 0)


luaReportError :: MVar [String] -> PreCFunction
luaReportError errorsList luaState = do
    isString <- lua_isstring luaState 1

    if fromLuaBool isString
      then do
        cstr <- lua_tolstring luaState 1 nullPtr
        msg <- if cstr /= nullPtr
               then peekCString cstr
               else return "Unknown error"
        
        liftIO $ modifyMVar_ errorsList $ \current -> return (msg : current)
      else
        liftIO $ modifyMVar_ errorsList $ \current -> return ("No error message for some reason" : current)
    
    lua_pop luaState 1
    return (NumResults 0)


hsfact :: Int -> Int
hsfact n
  | n < 0     = 0
  | n == 0    = 1
  | otherwise = n * hsfact (n - 1)


