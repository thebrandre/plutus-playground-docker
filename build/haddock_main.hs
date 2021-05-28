{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Main where

import qualified Servant.Server.StaticFiles as Static
import qualified Servant.Server as Server
import Servant.API ( Raw, type (:>) )
import Servant
    ( Proxy(..),
      Application,
      Raw,
      type (:>),
      serve,
      serveDirectoryWebApp)
import Data.Kind ()
import Network.Wai.Handler.Warp (run)
import System.Directory ( getSymbolicLinkTarget )
import System.FilePath.Posix ((</>))
import System.Environment (getArgs)
import System.Exit as Exit ( die )

type Haddock = "plutus-haddock" :> Raw

serverPort :: Int
serverPort = 8081

server :: FilePath -> Server.Server Haddock
server = serveDirectoryWebApp

myApi :: Proxy Haddock
myApi = Proxy

app :: FilePath -> Application
app = serve myApi . server

main :: IO ()
main = do
    args <- getArgs
    rootPath <- 
      case args of
        "-s":pathToHaddockSymLink:_  -> getSymbolicLinkTarget pathToHaddockSymLink
        "-p":pathToNixStoreHaddock:_ -> return pathToNixStoreHaddock
        _                            -> die "unrecognize input params. Use -s <path/to/haddock/symbolic/link> or -p <path/to/nix/store/haddock/> "
    let indexPath = rootPath </> "share" </> "doc"
    putStrLn $ "running plutus documentation in http://localhost:" <> show serverPort <> "/plutus-haddock/index.html"
    run serverPort $ app indexPath
