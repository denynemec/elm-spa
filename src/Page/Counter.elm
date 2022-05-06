module Page.Counter exposing (Model, Msg, init, update, view)

import Browser
import Header
import Html
import Html.Events as Events
import Route


type Model
    = ModelInternal Int


type Msg
    = Increment


init : ( Model, Cmd Msg )
init =
    ( ModelInternal 42
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update Increment (ModelInternal counter) =
    ( ModelInternal <| counter + 1
    , Cmd.none
    )


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg (ModelInternal counter) =
    { title = "Counter Page"
    , body =
        [ Header.view Route.Counter
        , Html.map wrapMsg <|
            Html.div []
                [ Html.h1 [] [ Html.text "Counter" ]
                , Html.text <| String.fromInt counter
                , Html.button [ Events.onClick Increment ] [ Html.text "Increment" ]
                ]
        ]
    }
