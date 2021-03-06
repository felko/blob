module Blob.Parsing.Types
( Expr(..) , Literal(..), Pattern(..)                 -- Expressions
, Associativity(..) , Fixity(..) , CustomOperator(..) -- Custom operators
, Parser , ParseState(..)                             -- Global
, Program(..) , Statement(..)                         -- AST
, Type(..), CustomType(..)                            -- Types
) where

import qualified Data.MultiMap as MMap (MultiMap)
import qualified Data.Map as Map (Map)
import qualified Text.Megaparsec as Mega (Pos, ParsecT)
import Data.Text (Text)
import Data.Void (Void)
import Control.Monad.Combinators.Expr (Operator)
import Control.Monad.State (State)
import qualified Blob.Inference.Types as I (Scheme(..))

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
          | EMatch Expr [(Pattern, Expr)]
    deriving (Show, Eq, Ord)

data Pattern = Wildcard         -- _
             | PId String       -- a basic value like `a`
             | PInt Integer     -- a basic value like `0`
             | PDec Double      -- a basic value like `0.0`
             | PStr String      -- a basic value like `"0"`
             | PTuple [Pattern] -- a basic value like `(a, b)`
             | PList [Pattern]  -- a basic value like `[a, b]`
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
               | TypeDeclaration CustomType
               | Empty -- Just a placeholder, when a line is a comment, for example.
    deriving (Eq, Ord, Show)

---------------------------------------------------------------------------------------------
{- Types -}

data Type = TId String            -- Type
          | TTuple [Type]         -- (a, ...)
          | TArrow Expr Type Type -- a ->[n] b -o ...
          | TVar String           -- a...
          | TApp Type Type        -- Type a...
          | TList Type            -- [a]
    deriving (Eq, Ord, Show)

data CustomType = TSum String (Map.Map String I.Scheme) | TProd String (String, I.Scheme)
    deriving (Eq, Ord, Show)