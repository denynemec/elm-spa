module Styles exposing
    ( containerStyle
    , formButtonStyle
    , formInputStyle
    , formStyle
    , listItemStyleAttributes
    , mainStyleAttributes
    , todoCheckStyle
    , todoListErrorStyle
    , todoListListStyle
    , todoStyle
    )

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


containerStyle : List (Attribute msg)
containerStyle =
    [ Attributes.style "width" "30rem"
    , Attributes.style "margin" "auto"
    , Attributes.style "font-family" "sans-serif"
    , Attributes.style "color" "#0D0D0D"
    ]


formStyle : List (Attribute msg)
formStyle =
    [ Attributes.style "display" "flex"
    , Attributes.style "margin-bottom" "1rem"
    ]


formInputStyle : List (Attribute msg)
formInputStyle =
    [ Attributes.style "flex-grow" "1"
    , Attributes.style "font-size" "1rem"
    , Attributes.style "padding" ".75rem"
    , Attributes.style "border-radius" ".5rem 0 0 .5rem"
    , Attributes.style "border" "1px solid #D8D9D7"
    , Attributes.style "outline" "none"
    ]


formButtonStyle : List (Attribute msg)
formButtonStyle =
    [ Attributes.style "background" "#70898C"
    , Attributes.style "color" "#fff"
    , Attributes.style "border" "none"
    , Attributes.style "border-radius" "0 .5rem .5rem 0"
    , Attributes.style "font-size" "1rem"
    , Attributes.style "cursor" "pointer"
    , Attributes.style "width" "5rem"
    , Attributes.style "outline" "none"
    ]


todoListListStyle : List (Attribute msg)
todoListListStyle =
    [ Attributes.style "padding" "0"
    , Attributes.style "margin" "0"
    ]


todoListErrorStyle : List (Attribute msg)
todoListErrorStyle =
    [ Attributes.style "padding" ".75rem"
    , Attributes.style "color" "#900"
    , Attributes.style "background" "#fee"
    , Attributes.style "border-radius" ".5rem"
    ]


todoStyle : List (Attribute msg)
todoStyle =
    [ Attributes.style "list-Attributes.style-type" "none"
    , Attributes.style "display" "flex"
    , Attributes.style "margin-bottom" ".5rem"
    , Attributes.style "background" "#D8D9D7"
    , Attributes.style "padding" ".75rem"
    , Attributes.style "border-radius" ".5rem"
    ]


todoCheckStyle : List (Attribute msg)
todoCheckStyle =
    [ Attributes.style "width" "1rem"
    , Attributes.style "height" "1rem"
    , Attributes.style "border" "1px solid #0D0D0D"
    , Attributes.style "border-radius" "50%"
    , Attributes.style "margin-right" ".5rem"
    , Attributes.style "text-align" "center"
    , Attributes.style "cursor" "pointer"
    ]
