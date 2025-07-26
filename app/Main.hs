{-# LANGUAGE OverloadedStrings #-}

import Test.WebDriver
import Test.WebDriver.Commands
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Lazy as BSL

import HsLua.Core
import qualified Data.ByteString as B
import LuaDSLCore

config :: WDConfig
config = useBrowser (chrome {chromeOptions = ["--headless", "--disable-gpu"]}) defaultConfig {
    wdPort = 62363,
    wdBasePath = ""
}


action :: WD()
action = do 
    openPage "https://example.com"
    saveScreenshot "screen.png"



main :: IO ()
main = do
  putStrLn "Calling Lua"
  luaStatus <- runLuaTest "./LuaTestScripts/Simple/factorial.lua"
  putStrLn ("Lua finished with status '" ++ show luaStatus ++ "'.")

--main = runSession config action


luaProgram :: B.ByteString
luaProgram = B.concat
  [ "local a, b = 0, 1\n"
  , "for i = 0, 10 do\n"
  , "  print(i, a)\n"
  , "  a, b = b, a + b\n"
  , "end\n"
  ]