module Form.Filter exposing (Model, Msg, init, update, view)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Styles


type Model
    = Model String


init : ( Model, Cmd Msg )
init =
    ( Model "", Cmd.none )


type Msg
    = Inserted String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg (Model value) =
    case msg of
        Inserted insertedValue ->
            ( Model insertedValue
            , Cmd.none
            )


view : (Msg -> msg) -> (String -> msg) -> Model -> Html.Html msg
view wrapMsg submitMsg (Model value) =
    Html.form ((Events.onSubmit <| submitMsg value) :: Styles.formStyle)
        [ Html.input (Styles.formInputStyle ++ [ Attributes.type_ "text", Attributes.value value, Events.onInput (wrapMsg << Inserted) ]) []
        , Html.button (Styles.formButtonStyle ++ [ Attributes.type_ "submit" ]) [ Html.text "Add" ]
        ]
