module Page.NotFound exposing (view)

import Browser
import Html


view : Browser.Document msg
view =
    { title = "Not Found Page"
    , body = [ Html.main_ [] [ Html.h1 [] [ Html.text "Not Found Page !!!" ] ] ]
    }
