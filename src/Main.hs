--------------------------------------------------------------------
-- |
-- Module     : Main
-- Copyright  : (c) Conor Reynolds 2016
-- License    : MIT
-- Maintainer : reynolds.conor@gmail.com
-- Stability  : experimental
-- Portability: non-portable
--
--------------------------------------------------------------------

import Control.Concurrent  (threadDelay)
import Control.Monad       (forM_)
import Data.Char           (toLower)
import Data.Word           (Word64)
import Grid
import Options.Applicative
import System.Console.ANSI
import System.Environment  (getProgName)

type Rows = Int
type Cols = Int
type FPS = Int

-- | Command line options
data Opts = PDef String FPS
          | Rand Rows Cols FPS

main :: IO ()
main = execParser opts >>= run
  where
    opts = info (availableCommands <**> helper)
       ( fullDesc
      <> progDesc "Yet another implementation of Conway's Game of Life."
      <> header "gol - Game of Life" )

    availableCommands =
      subparser
        ( command "random" (info (randomGridParser <**> helper)
          ( progDesc "Initialises a random grid with given dimensions" ))
       <> command "select" (info (pdefGridParser <**> helper)
          ( progDesc "Initialises a predefined grid")))

    randomGridParser = Rand
      <$> argument auto (metavar "ROWS" <> help "Number of rows")
      <*> argument auto (metavar "COLS" <> help "Number of cols")
      <*> ( option auto
            ( long "fps"
           <> metavar "FPS"
           <> help "Frames per second")
           <|> pure 10 )

    pdefGridParser = PDef
      <$> argument str  (metavar "rowOf10 | lwss | gun" <> help "Grid name")
      <*> ( option auto
            ( long "fps"
           <> metavar "FPS"
           <> help "Frames per second" )
           <|> pure 10 )

    run (Rand rs cs hz) =
      randomGrid rs cs >>= loop hz

    run (PDef s hz) = do
      pn <- getProgName
      -- TODO: This should be replaced by a data type, since the bash
      --       autocompletion could be improved if it was.
      either putStrLn (loop hz) $ case map toLower s of
        "rowof10" -> Right rowOf10
        "lwss"    -> Right lwss
        "gun"     -> Right gliderGun
        _         -> Left $ "Unrecogised grid. Run '" ++ pn ++ " select -h' for help."

    loop 0 grid = do
      putStrLn "Not sure you actually wanted this but here anyway."
      print grid

    loop hz _ | hz <= 1 = putStrLn "No support for negative entropy (yet?)"

    loop hz grid = do
      let futureStates = iterate update grid
      forM_ futureStates $ \state -> do
        putStrLnBold $ " FPS: " ++ show hz
        print state
        threadDelay (10^6 `div` fromIntegral hz)
        clearScreen

----------------
--   STYLES   --
----------------

-- | Might move this into a Styles.hs file if we end up needing/wanting
--   much more styles.
putStrLnBold :: String -> IO ()
putStrLnBold s = setSGR [SetConsoleIntensity BoldIntensity]
              >> putStrLn s
              >> setSGR []
