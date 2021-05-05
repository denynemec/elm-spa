module Page.TodoList exposing (Model, Msg, init, update, view)

import Browser
import Header
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Loader
import Route
import Styles


type Model
    = ModelInternal (List Todo) (Loader.Loader (List Todo))


type Msg
    = FetchedTodos (Result Http.Error (List Todo))
    | ClickedDeleteTodo TodoId
      -- | ClickedCompleteTodo TodoId Bool
    | DeletedResponse TodoId (Result Http.Error ())


type alias TodoId =
    Int


type alias Todo =
    { id : TodoId
    , title : String
    }


init : String -> ( Model, Cmd Msg )
init api =
    ( ModelInternal [] Loader.loading
    , fetchTodos api
    )


fetchTodos : String -> Cmd Msg
fetchTodos api =
    Http.get
        { url = api ++ "todos"
        , expect = Http.expectJson FetchedTodos decodeTodos
        }


decodeTodos : Decode.Decoder (List Todo)
decodeTodos =
    Decode.list decodeTodo


decodeTodo : Decode.Decoder Todo
decodeTodo =
    Decode.succeed Todo
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "title" Decode.string


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update api msg (ModelInternal todos _) =
    case msg of
        FetchedTodos todosResponse ->
            ( ModelInternal (Result.withDefault todos todosResponse) <| Loader.handleResponse todosResponse
            , Cmd.none
            )

        ClickedDeleteTodo todoId ->
            ( ModelInternal todos Loader.loading
            , deleteTodoCmd api todoId
            )

        DeletedResponse todoId response ->
            let
                updatedTodos =
                    todos
                        |> List.filter (.id >> (/=) todoId)
            in
            ( response
                |> Result.map (always updatedTodos)
                |> Loader.handleResponse
                |> ModelInternal updatedTodos
            , Cmd.none
            )


deleteTodoCmd : String -> TodoId -> Cmd Msg
deleteTodoCmd api todoId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = api ++ "todos/" ++ String.fromInt todoId
        , body = Http.emptyBody
        , expect = Http.expectWhatever (DeletedResponse todoId)
        , timeout = Nothing
        , tracker = Nothing
        }


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg (ModelInternal todos model) =
    let
        child =
            case model of
                Loader.Loading ->
                    [ Html.text "Loading todo list ..." ]

                Loader.Error _ ->
                    [ Html.text "Todo list error !!!" ]

                Loader.Success _ ->
                    todosView todos
    in
    { title = "Todo List page"
    , body =
        [ Header.view Route.TodoList
        , child
            |> Html.main_ Styles.mainStyleAttributes
            |> Html.map wrapMsg
        ]
    }


todosView : List Todo -> List (Html Msg)
todosView =
    List.map todoView


todoView : Todo -> Html Msg
todoView { id, title } =
    Html.li Styles.listItemStyleAttributes
        [ Html.input
            [ Attributes.type_ "checkbox" ]
            []
        , Html.text title
        , Html.button
            [ Events.onClick <| ClickedDeleteTodo id ]
            [ Html.text "Remove todo" ]
        ]
