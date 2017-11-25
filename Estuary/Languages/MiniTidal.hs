module Estuary.Languages.MiniTidal (miniTidalPattern) where

import Text.ParserCombinators.Parsec
import Data.List (intercalate)
import Data.Bool (bool)
import qualified Sound.Tidal.Context as Tidal

miniTidalPattern :: String -> Tidal.ParamPattern
miniTidalPattern x = either (const Tidal.silence) id $ parse miniTidalParser "(unknown)" x

miniTidalParser :: GenParser Char a Tidal.ParamPattern
miniTidalParser = spaces >> patternOrTransformedPattern

transformedPattern1 :: GenParser Char a (Tidal.ParamPattern)
transformedPattern1 = do
  x <- patternTransformation
  char '$'
  spaces
  y <- patternOrTransformedPattern
  spaces
  return $ x y

transformedPattern2 :: GenParser Char a (Tidal.ParamPattern)
transformedPattern2 = do
  x <- patternTransformation
  char '('
  spaces
  y <- patternOrTransformedPattern
  spaces
  char ')'
  return $ x y

patternOrTransformedPattern :: GenParser Char a (Tidal.ParamPattern)
patternOrTransformedPattern = choice [
  try transformedPattern1,
  try transformedPattern2,
  specificPattern
  ]

patternTransformation :: GenParser Char a (Tidal.ParamPattern -> Tidal.ParamPattern)
patternTransformation = choice [
  try (string "brak" >> spaces >> return Tidal.brak),
  try (string "rev" >> spaces >> return Tidal.rev)
  ]

specificPattern :: GenParser Char a (Tidal.ParamPattern)
specificPattern = choice [
  try (string "s" >> spaces >> genericPattern >>= return . Tidal.s),
  try (string "n" >> spaces >> genericPattern >>= return . Tidal.n),
  try (string "up" >> spaces >> genericPattern >>= return . Tidal.up),
  try (string "vowel" >> spaces >> genericPattern >>= return . Tidal.vowel),
  try (string "pan" >> spaces >> genericPattern >>= return . Tidal.pan),
  try (string "shape" >> spaces >> genericPattern >>= return . Tidal.shape)
  ]

genericPattern :: Tidal.Parseable b => GenParser Char a (Tidal.Pattern b)
genericPattern = do
  char '"'
  x <- many (noneOf "\"")
  char '"'
  return $ Tidal.p x
