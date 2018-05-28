module Estuary.Languages.Test1 (test1) where

import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Number
import qualified Sound.Tidal.Context as Tidal
--lima
-- <nombre sonido> <transf1> <parametros>

lengExpr :: GenParser Char a Tidal.ParamPattern
lengExpr = do
--coloca aquí los parsers
  espacios
  s <- sonidos
  espacios
  t <- trans
  espacios
  return $ t $ nuestroTextoATidal s

nuestroTextoATidal ::  String  -> Tidal.ParamPattern
nuestroTextoATidal s = Tidal.s $ Tidal.p s

sonidos :: GenParser Char a String
sonidos = choice [
        --coloca aqui los nombres de tus muestras de audio
        --ej. try (string "bombo" >> espacios >> "bd")
        try (string "trueno" >> espacios >> return "bd" ),
        try (string "rama" >> espacios >> return "hh" ),
        try (string "cascada" >> espacios >> return "808" ),
        try (string "volcan" >> espacios >> return "bass1"),
        try (silencios >> espacios >> return "~")
        ]

trans :: GenParser Char a (Tidal.ParamPattern -> Tidal.ParamPattern)
trans = choice [
              --coloca aqui los nombres de tus transformaciones
         try (string "eco" >> spaces >>  int >>= return . Tidal.striate),
         try (string "este" >> spaces >> fractional3 False  >>= return . Tidal.fast),
         try (string "palta con el tombo">> spaces >> int >>= return . Tidal.iter),
         try (string "mi cerro causa" >> spaces >> int >>= return . Tidal.chop),
         try (descartarTexto >> return id)
                ]

--descartar espacios
espacios :: GenParser Char a String
espacios = many (oneOf " ")


--descartar espacios
silencios :: GenParser Char a String
silencios = many (oneOf "~")


--descartar texto
descartarTexto :: GenParser Char a String
descartarTexto = many (oneOf "\n")

exprStack :: GenParser Char a Tidal.ParamPattern
exprStack = do
   expr <- many lengExpr
   return $ Tidal.stack expr

test1 :: String -> Tidal.ParamPattern
test1 s = either (const Tidal.silence) id $ parse exprStack "unNombreparaTuLenguage" s
