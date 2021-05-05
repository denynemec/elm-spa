module Route exposing (Route(..), fromUrl, href)

import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url
import Url.Parser as Parser



-- ROUTING


type Route
    = TodoList
    | Posts


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map TodoList (Parser.s "todo-list")
        , Parser.map Posts (Parser.s "posts")
        ]


href : Route -> Attribute msg
href =
    Attributes.href << routeToString


fromUrl : Url.Url -> Maybe Route
fromUrl =
    Parser.parse parser


routeToString : Route -> String
routeToString route =
    case route of
        TodoList ->
            "todo-list"

        Posts ->
            "posts"
