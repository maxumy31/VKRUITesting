module LuaDSLBrowserControl where
import HsLua.Core
import Lua
import HsLua.Core.Types
import Foreign
import Foreign.C
import Control.Concurrent
import Test.WebDriver
import Text.ParserCombinators.ReadPrec (Prec)
import qualified Data.Text as T


luaReadStringFromStack :: State -> IO (Maybe String)
luaReadStringFromStack luaState = do
    isString <- lua_isstring luaState 1
    if fromLuaBool isString
      then do
        cstr <- lua_tolstring luaState 1 nullPtr
        if cstr /= nullPtr
          then Just <$> peekCString cstr
          else return Nothing
      else
        return Nothing

luaReadIntFromStack :: State -> IO (Maybe Int)
luaReadIntFromStack luaState = do
    isInteger <- lua_isinteger luaState 1
    if fromLuaBool isInteger
      then do
        val <- lua_tointegerx luaState 1 nullPtr
        return $ Just (fromIntegral  val :: Int)
      else
        return Nothing



luaTakeAndSaveScreenshot :: MVar (WD()) -> PreCFunction
luaTakeAndSaveScreenshot mvar luaState = do
    maybePath <- luaReadStringFromStack luaState
    case maybePath of
        Just path -> liftIO $ modifyMVar_ mvar $ \currentWdAction -> return (currentWdAction >> saveScreenshot path)
        Nothing -> return ()
        
    lua_pop luaState 1
    return (NumResults 0)


luaLeftMouseClick :: MVar (WD()) -> PreCFunction
luaLeftMouseClick mvar luaState = do
    maybeX <- luaReadIntFromStack luaState
    case maybeX of
        Nothing -> return ()
        Just x -> do
            lua_pop luaState 1
            maybeY <- luaReadIntFromStack luaState
            case maybeY of
                Nothing -> return ()
                Just y -> liftIO $ modifyMVar_ mvar $ \currentWdAction -> 
                    return (currentWdAction >> moveTo (x,y) >> clickWith LeftButton)
    return (NumResults 0)

luaExecuteJavascriptCode :: MVar (WD()) -> PreCFunction
luaExecuteJavascriptCode mvar luaState = do
    maybeCode <- luaReadStringFromStack luaState
    case maybeCode of 
        Just code -> do
            lua_pop luaState 1
            liftIO $ modifyMVar_ mvar $ \currentWdAction -> 
                return (currentWdAction >> executeJS [] (T.pack code))
        Nothing -> return ()
    return (NumResults 0)