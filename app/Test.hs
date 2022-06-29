{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NoFieldSelectors #-}

module Test where

data MyRecord = MyRecord
  { a :: String
  , b :: Integer
  } deriving (Eq, Show)

x = MyRecord { a = "Hello", b = 12 }

y = x.a ++ show x.b