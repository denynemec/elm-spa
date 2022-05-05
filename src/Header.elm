module Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attributes
import Route


view : Route.Route -> Html msg
view activeRoute =
    routeList
        |> List.map (\route -> navigationLinkView (activeRoute == route) route)
        |> Html.nav
            [ Attributes.style "display" "flex"
            , Attributes.style "flex-direction" "row"
            , Attributes.style "height" "100px"
            , Attributes.style "background-color" "#d2cbc4"
            , Attributes.style "padding" "20px 0 0 0"
            , Attributes.style "justify-content" "center"
            ]


navigationLinkView : Bool -> Route.Route -> Html msg
navigationLinkView isActive currentRoute =
    let
        activeLinkStyles =
            if isActive then
                [ Attributes.style "color" "#456456"
                , Attributes.style "border-style" "solid"
                , Attributes.style "border-color" "#456456"
                , Attributes.style "border-width" "0 0 3px 0"
                ]

            else
                []
    in
    Html.div [ Attributes.style "padding" "0 10px" ]
        [ Html.a
            ([ Attributes.style "color" "#000000"
             , Attributes.style "text-decoration" "none"
             , Attributes.style "padding" "10px"
             , Route.href currentRoute
             ]
                ++ activeLinkStyles
            )
            [ Html.text <| routeToLinkText currentRoute ]
        ]


routeList : List Route.Route
routeList =
    [ Route.TodoList
    ]


routeToLinkText : Route.Route -> String
routeToLinkText route =
    case route of
        Route.TodoList ->
            "Todo list"
