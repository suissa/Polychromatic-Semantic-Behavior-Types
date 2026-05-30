module Main where

import Forger
import qualified Data.Map as Map
import Control.Monad (unless)

main :: IO ()
main = do
    unless (getPrimitiveType 5 == (5 :: Int)) $ error "Test failed"

    unless (convertToPrimitive (PString " 123 ") == PInt 123) $ error "Test failed"
    unless (convertToPrimitive (PString "true") == PBool True) $ error "Test failed"
    unless (convertToPrimitive (PString "{}") == PInt 0) $ error "Test failed"

    let m = Map.fromList [("productPrice", PString "10.5"), ("deliveryPrice", PDouble 2.5)]
    unless (processValueMap m == PDouble 13.0) $ error "Test failed"

    unless (validate "PersonEmail" (PString "test@example.com") == True) $ error "Test failed"
    unless (validate "PersonEmail" (PString "invalid-email") == False) $ error "Test failed"

    putStrLn "Haskell tests passed"
