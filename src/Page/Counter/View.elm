module Page.Counter.View exposing (view)

import Browser
import Header
import Html
import Html.Events as Events
import Page.Counter.Model as Model
import Page.Counter.Msg as Msg
import Route


view : (Msg.Msg -> msg) -> Model.Model -> Browser.Document msg
view wrapMsg (Model.ModelInternal counter) =
    { title = "Counter Page"
    , body =
        [ Header.view Route.Counter2
        , Html.map wrapMsg <|
            Html.div []
                [ Html.h1 [] [ Html.text "Counter" ]
                , Html.text <| String.fromInt counter
                , Html.button [ Events.onClick Msg.Increment ] [ Html.text "Increment" ]
                ]
        ]
    }
