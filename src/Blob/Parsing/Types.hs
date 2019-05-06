module Blob.Parsing.Types
( Expr(..) , Literal(..)                              -- Expressions
, Associativity(..) , Fixity(..) , CustomOperator(..) -- Custom operators
, Parser , ParseState(..)                             -- Global
, Program(..) , Statement(..)                         -- AST
, Type(..)                                            -- Types
) where

import qualified Data.MultiMap as MMap (MultiMap)
import qualified Text.Megaparsec as Mega (Pos, ParsecT)
import Data.Text (Text)
import Data.Void (Void)
import Control.Monad.Combinators.Expr (Operator)
import Control.Monad.State (State)

---------------------------------------------------------------------------------------------
{- Global -}

type Parser = Mega.ParsecT Void Text (State ParseState)

data ParseState = ParseState
    { operators :: MMap.MultiMap Integer (Operator Parser Expr)
    , currentIndent :: Mega.Pos }

---------------------------------------------------------------------------------------------
{- Expressions -}

data Expr = EId String
          | ELit Literal
          | ELam String Expr
          | EApp Expr Expr
          | ETuple [Expr]
          | EList [Expr]
    deriving (Show, Eq, Ord)

data Literal = LStr String
             | LInt Integer
             | LDec Double
    deriving (Show, Eq, Ord)

data Associativity = L
                   | R
                   | N
    deriving (Show, Eq, Ord)

data Fixity = Infix' Associativity Integer
            | Prefix' Integer
            | Postfix' Integer
    deriving (Show, Eq, Ord)

data CustomOperator = CustomOperator { name :: Text
                                     , fixity :: Fixity }
    deriving (Show, Eq, Ord)


---------------------------------------------------------------------------------------------
{- AST -}

newtype Program = Program [Statement]
    deriving (Eq, Ord, Show)

data Statement = Declaration String Type
               | Definition String Expr
               | OpDeclaration String Fixity
               | Empty -- Just a placeholder, when a line is a comment, for example.
    deriving (Eq, Ord, Show)

---------------------------------------------------------------------------------------------
{- Types -}
data Type = TId String            -- Type
          | TTuple [Type]         -- (a, ...)
          | TArrow Expr Type Type -- a ->[n] b ->[n'] ...
          | TVar String           -- a...
          | TApp Type Type        -- Type a...
          | TList Type            -- [a]
    deriving (Eq, Ord, Show)
