module Main (main) where

import           Control.Monad
import qualified Control.Monad.State as S

import           Data.Maybe
import qualified Data.Foldable as F

import           Test.HUnit

import           Chess.Move
import           Chess.Board


perft :: Int -> Board -> Integer
perft d = S.evalState (perft' d)
  where perft' d' = do
          ms <- liftM (F.toList . moves) S.get
          if d' == 1
            then return $ fromIntegral $ length ms
            else
            do let step m = do
                     doMoveM m
                     result <- perft' (d' - 1)
                     undoMoveM m
                     return result                            
               liftM sum $ mapM step ms


-- from http://chessprogramming.wikispaces.com/Perft+Results
initialPerftResult :: Int -> Integer
initialPerftResult 1  = 20
initialPerftResult 2  = 400
initialPerftResult 3  = 8902
initialPerftResult 4  = 197281
initialPerftResult 5  = 4865609
initialPerftResult 6  = 119060324
initialPerftResult 7  = 3195901860
initialPerftResult 8  = 84998978956
initialPerftResult 9  = 2439530234167
initialPerftResult 10 = 69352859712417
initialPerftResult 11 = 2097651003696806
initialPerftResult 12 = 62854969236701747
initialPerftResult 13 = 1981066775000396239
initialPerftResult _  = undefined

testInitialPos :: Int -> Test
testInitialPos n = perft n initialBoard ~?= initialPerftResult n

initialTests :: Test
initialTests  =
  TestList [ TestLabel ("Initial Perft " ++ show n) $ testInitialPos n | n <- [1 .. 5] ]


ruyLopezPosition :: Board
ruyLopezPosition = fromJust $ fromFEN "r1bqkbnr/1pp2ppp/p1p5/4N3/4P3/8/PPPP1PPP/RNBQK2R b KQkq - 0 5"


ruyLopezPerftResult :: Int -> Integer
ruyLopezPerftResult 1 =           36
ruyLopezPerftResult 2 =         1147
ruyLopezPerftResult 3 =        41558
ruyLopezPerftResult 4 =      1322527
ruyLopezPerftResult 5 =     48184273
ruyLopezPerftResult 6 =   1552389766

testRuyLopez :: Int -> Test
testRuyLopez n = perft n ruyLopezPosition ~?= ruyLopezPerftResult n


ruyLopezTests :: Test
ruyLopezTests =
  TestList [ TestLabel ("Ruy Lopez Perft " ++ show n) $ testRuyLopez n | n <- [1 .. 6] ]


allTests :: Test
allTests = TestList [initialTests, ruyLopezTests]
  

main :: IO ()
main = do
  _ <- runTestTT allTests  
  return ()