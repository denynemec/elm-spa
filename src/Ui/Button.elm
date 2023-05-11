module Ui.Button exposing (view)

import Html
import Html.Events as Events
import Styles


type alias Model msg =
    { msg : msg
    , label : String
    }


view : Model msg -> Html.Html msg
view { msg, label } =
    let
        attributes =
            Events.onClick msg :: Styles.formButtonStyle
    in
    Html.button attributes [ Html.text label ]
