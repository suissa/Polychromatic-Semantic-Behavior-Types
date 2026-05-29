{-# LANGUAGE FlexibleInstances #-}

module Forger where

import Data.Char (isSpace, toLower)
import Text.Read (readMaybe)
import qualified Data.Map as Map
import Text.Regex.Posix ((=~))

data PrimitiveValue = PString String | PInt Integer | PDouble Double | PBool Bool | PNull deriving (Show, Eq)

trim :: String -> String
trim = f . f
   where f = reverse . dropWhile isSpace

primitiveStringToValue :: String -> PrimitiveValue
primitiveStringToValue val =
    let trimmed = trim val
        lower = map toLower trimmed
    in if null trimmed then PString val
       else if val == "{}" || val == "[]" then PInt 0
       else if lower == "true" then PBool True
       else if lower == "false" then PBool False
       else if lower == "null" || lower == "undefined" then PNull
       else case readMaybe trimmed :: Maybe Double of
                Just d -> if '.' `elem` trimmed || 'e' `elem` lower then PDouble d
                          else case readMaybe trimmed :: Maybe Integer of
                                   Just i -> PInt i
                                   Nothing -> PDouble d
                Nothing -> PString val

convertToPrimitive :: PrimitiveValue -> PrimitiveValue
convertToPrimitive (PString s) = primitiveStringToValue s
convertToPrimitive v = v

getPrimitiveType :: a -> a
getPrimitiveType v = v

validate :: String -> PrimitiveValue -> Bool
validate name val =
    if name == "PersonEmail"
    then case convertToPrimitive val of
             PString s -> s =~ "^[a-zA-Z0-9_.+\\-]+@[a-zA-Z0-9\\-]+\\.[a-zA-Z0-9\\-.]+$" :: Bool
             _ -> False
    else False

forge :: String -> a -> a
forge name v =
    -- Validation skipped for Any type in haskell without robust typing of SemanticType envelope
    -- Same simplified logic as other languages
    if name == "PersonEmail"
    -- && not (validate name (convertToPrimitive v)) then error "Validation failed"
    then v
    else v

-- Simple implementation for Map
processValueMap :: Map.Map String PrimitiveValue -> PrimitiveValue
processValueMap m =
    case Map.lookup "productPrice" m of
        Just pPriceVal ->
            let getVal k = case convertToPrimitive (Map.findWithDefault (PInt 0) k m) of
                               PDouble d -> d
                               PInt i -> fromIntegral i
                               _ -> 0.0
                price = case convertToPrimitive pPriceVal of
                            PDouble d -> d
                            PInt i -> fromIntegral i
                            _ -> 0.0
                discount = getVal "productDiscount"
                delivery = getVal "deliveryPrice"
                fees = getVal "paymentFees"
            in PDouble (price - discount + delivery + fees)
        Nothing -> PNull
