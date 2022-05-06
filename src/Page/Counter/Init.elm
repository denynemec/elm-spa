module Page.Counter.Init exposing (init)

import Page.Counter.Model as Model
import Page.Counter.Msg as Msg


init : ( Model.Model, Cmd Msg.Msg )
init =
    ( Model.ModelInternal 42
    , Cmd.none
    )
