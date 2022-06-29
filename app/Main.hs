module Main where

import GHC
import System.Process (readProcess)
import Control.Monad.IO.Class
import Control.Monad
import GHC.Driver.Env
import GHC.Utils.Outputable

import GHC.Plugins
import GHC
import Data.Version
import GHC.Unit.Env
import GHC.Driver.Monad

import GHC.Data.FastString
import GHC.Iface.Ext.Ast ( mkHieFile )
import GHC.Data.Bag (bagToList)
import GHC.Tc.Module
import Data.Maybe
import GHC.Iface.Ext.Types

main = let fn = "app/Test.hs"
       in dumpHieAST fn >> dumpModCore fn

dumpHieAST :: String -> IO ()
dumpHieAST fn = runAndSetupGhc fn $ do
  hscEnv <- getSession
  let mod_summary:_ = mgModSummaries $ hsc_mod_graph hscEnv
  typechecked <- parseModule mod_summary >>= typecheckModule

  hieFile <- liftIO $ let (tc_result, _) = tm_internals_ typechecked
                          rn_info = getRenamedStuff tc_result
                      in runHsc hscEnv $ mkHieFile mod_summary (tc_result) (fromJust rn_info)
  let hieast = hie_asts hieFile

  liftIO $ (putStrLn . draw) hieast

dumpModCore :: String -> IO ()
dumpModCore fn = runAndSetupGhc fn $ do
  hscEnv <- getSession
  let mod_summary:_ = mgModSummaries $ hsc_mod_graph hscEnv
  desugared <- parseModule mod_summary >>= typecheckModule >>= desugarModule
  let coredump = mg_binds $ coreModule desugared

  liftIO $ (putStrLn . draw) coredump

runAndSetupGhc :: String -> Ghc () -> IO ()
runAndSetupGhc fn res = do
  libdir:_ <- liftIO $ lines <$> readProcess "ghc" ["--print-libdir"] ""
  runGhc (Just libdir) $ setupGhc fn >> res

setupGhc :: GhcMonad m => String -> m ()
setupGhc fn = do
  df1 <- getSessionDynFlags
  logger <- getLogger
  let cmdOpts = []
  (df2, leftovers, warns) <- parseDynamicFlags logger df1 (map noLoc cmdOpts)
  setSessionDynFlags df2

  target <- guessTarget fn Nothing
  addTarget target
  _ <- load LoadAllTargets
  return ()

draw :: Outputable p => p -> String
draw =   renderWithContext (defaultSDocContext
  {
    sdocStyle = defaultUserStyle
  , sdocSuppressUniques = True
  , sdocCanUseUnicode = True
  }) . ppr