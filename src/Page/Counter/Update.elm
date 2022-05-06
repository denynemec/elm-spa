module Page.Counter.Update exposing (update)

import Page.Counter.Model as Model
import Page.Counter.Msg as Msg


update : Msg.Msg -> Model.Model -> ( Model.Model, Cmd Msg.Msg )
update Msg.Increment (Model.ModelInternal counter) =
    ( Model.ModelInternal <| counter + 1
    , Cmd.none
    )
