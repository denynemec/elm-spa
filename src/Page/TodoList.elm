module Page.TodoList exposing (Model, Msg, init, update, view)

import Api
import Browser
import Header
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Route
import Styles


type alias Model =
    { todoList : TodoList
    , newTodo : String
    }


type TodoList
    = Loading
    | Error String
    | Success (List TodoItem)


type alias TodoItem =
    { id : Int
    , name : String
    , completed : Bool
    }


getTodos : Api.Api -> Cmd Msg
getTodos =
    Api.get GotTodos decodeTodoList "todos"


postTodo : Api.Api -> String -> Cmd Msg
postTodo api label =
    let
        body =
            Encode.object [ ( "label", Encode.string label ) ]
    in
    Api.post SaveTodoResponse body "todos" api


putTodo : Api.Api -> TodoItem -> Cmd Msg
putTodo api todoItem =
    let
        body =
            Encode.object
                [ ( "label", Encode.string todoItem.name )
                , ( "completed", Encode.bool <| not todoItem.completed )
                ]
    in
    api
        |> Api.addAuthorizationHeader "My custom JWT Token value"
        |> Api.put (CompletedTodoItemResponse todoItem) body ("todos/" ++ String.fromInt todoItem.id)


decodeTodoList : Decode.Decoder (List TodoItem)
decodeTodoList =
    Decode.list decodeTodoItem


decodeTodoItem : Decode.Decoder TodoItem
decodeTodoItem =
    Decode.succeed TodoItem
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "label" Decode.string
        |> Pipeline.required "completed" Decode.bool


init : Api.Api -> ( Model, Cmd Msg )
init api =
    ( { todoList = Loading
      , newTodo = ""
      }
    , getTodos api
    )


type Msg
    = GotTodos (Result Http.Error (List TodoItem))
    | InsertedNewTodo String
    | ClickedAddTodo
    | SaveTodoResponse (Result Http.Error ())
    | CompletedTodo TodoItem
    | CompletedTodoItemResponse TodoItem (Result Http.Error ())
    | ClickedCompleted TodoItem


update : Api.Api -> Msg -> Model -> ( Model, Cmd Msg )
update api msg model =
    case msg of
        GotTodos result ->
            case result of
                Ok todos ->
                    ( { model | todoList = Success todos }, Cmd.none )

                Err _ ->
                    ( { model | todoList = Error "Unable to get TODOs" }, Cmd.none )

        InsertedNewTodo todo ->
            ( { model | newTodo = todo }, Cmd.none )

        ClickedAddTodo ->
            ( model, postTodo api model.newTodo )

        SaveTodoResponse result ->
            case result of
                Ok _ ->
                    ( model, getTodos api )

                Err _ ->
                    ( { model | todoList = Error "Unable to save TODOs" }, Cmd.none )

        ClickedCompleted todoItem ->
            let
                updatedTodoList =
                    case model.todoList of
                        Loading ->
                            model.todoList

                        Error _ ->
                            model.todoList

                        Success todos ->
                            todos
                                |> List.map
                                    (\todo ->
                                        if todo.id == todoItem.id then
                                            { todo | completed = not todoItem.completed }

                                        else
                                            todo
                                    )
                                |> Success
            in
            ( { model | todoList = updatedTodoList }
            , Cmd.none
            )

        CompletedTodo todoItem ->
            ( model, putTodo api todoItem )

        CompletedTodoItemResponse todoItem result ->
            let
                updatedTodoList =
                    case model.todoList of
                        Loading ->
                            model.todoList

                        Error _ ->
                            model.todoList

                        Success todos ->
                            todos
                                |> List.map
                                    (\todo ->
                                        if todo.id == todoItem.id then
                                            { todo | completed = not todoItem.completed }

                                        else
                                            todo
                                    )
                                |> Success
            in
            case result of
                Ok _ ->
                    ( { model | todoList = updatedTodoList }, Cmd.none )

                Err _ ->
                    ( { model | todoList = Error "Unable to update todo" }, Cmd.none )


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg model =
    { title = "Todo List Page"
    , body =
        [ Header.view Route.TodoList
        , Html.map wrapMsg <|
            Html.div Styles.containerStyle
                [ Html.h1 [] [ Html.text "Todo list" ]
                , todoForm model
                , todoListView model.todoList
                ]
        ]
    }


todoListView : TodoList -> Html.Html Msg
todoListView todoList =
    case todoList of
        Loading ->
            Html.div [] [ Html.text "Loading..." ]

        Error error ->
            Html.div Styles.todoListErrorStyle [ Html.text error ]

        Success todos ->
            Html.ul Styles.todoListListStyle <| List.map todoView todos


todoView : TodoItem -> Html.Html Msg
todoView todoItem =
    let
        checkText =
            if todoItem.completed then
                "✓"

            else
                ""
    in
    Html.li Styles.todoStyle
        [ Html.div (Styles.todoCheckStyle ++ [ Events.onClick <| CompletedTodo todoItem ]) [ Html.text checkText ]
        , Html.text todoItem.name
        ]


todoForm : Model -> Html.Html Msg
todoForm model =
    Html.div Styles.formStyle
        [ Html.input (Styles.formInputStyle ++ [ Attributes.type_ "text", Attributes.value model.newTodo, Events.onInput InsertedNewTodo ]) []
        , Html.button (Styles.formButtonStyle ++ [ Events.onClick ClickedAddTodo ]) [ Html.text "Add" ]
        ]
