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
config = useBrowser (chrome {chromeOptions = ["--headless", "--disable-gpu", "window-size=1920,1080"]}) defaultConfig {
    wdPort = 60318,
    wdBasePath = ""
}


action :: WD()
action = do 
    openPage "https://ru.wikipedia.org/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0"
    saveScreenshot "screen.png"



main :: IO ()
--main = runSession config action



main = do
  putStrLn "Calling Lua"
  luaStatus <- runLuaTest config "./LuaTestScripts/Simple/factorial.lua"
  putStrLn ("Lua finished with status '" ++ show luaStatus ++ "'.")



