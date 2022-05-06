module Route exposing (Route(..), fromUrl, href)

import Html exposing (Attribute)
import Html.Attributes as Attributes
import Url
import Url.Parser as Parser



-- ROUTING


type Route
    = TodoList
    | Counter
    | Counter2


parser : Parser.Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map TodoList (Parser.s "todo-list")
        , Parser.map Counter (Parser.s "counter")
        , Parser.map Counter2 (Parser.s "counter2")
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

        Counter ->
            "counter"

        Counter2 ->
            "counter2"
