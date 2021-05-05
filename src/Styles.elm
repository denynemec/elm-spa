module Styles exposing (listItemStyleAttributes, mainStyleAttributes)

import Html exposing (Attribute)
import Html.Attributes as Attributes


mainStyleAttributes : List (Attribute msg)
mainStyleAttributes =
    [ Attributes.style "flex-direction" "column"
    , Attributes.style "display" "flex"
    , Attributes.style "align-items" "center"
    , Attributes.style "padding" "20px 0 0 0"
    ]


listItemStyleAttributes : List (Attribute msg)
listItemStyleAttributes =
    [ Attributes.style "padding" "5px 0"
    ]
