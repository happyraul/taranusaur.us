module Route exposing (Route(..), fromUrl)

import Url
import Url.Parser as Parser exposing ((</>))



-- ROUTING


type Route
    = Index
    | Directory (Maybe String)
    | SetupVps
    | SetupGit
    | Vim


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ route Index Parser.top
        , route Directory (Parser.s "directory" </> Parser.fragment identity)
        , route SetupVps (Parser.s "setup-vps" </> Parser.top)
        , route SetupGit (Parser.s "setup-git" </> Parser.top)
        , route Vim (Parser.s "vim" </> Parser.top)
        ]


route : a -> Parser.Parser a Route -> Parser.Parser (Route -> c) c
route handler parse =
    Parser.map handler parse


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    Parser.parse parser url
