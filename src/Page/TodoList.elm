module Page.TodoList exposing (Model, Msg, init, update, view)

import Api
import Browser
import Form.Filter as Filter
import Header
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import RemoteData
import Route
import Styles


type alias Model =
    { todoList : RemoteData.RemoteData String (List TodoItem)
    , filter : Filter.Model
    }


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
    let
        ( filter, filterCmd ) =
            Filter.init
    in
    ( { todoList = RemoteData.Loading
      , filter = filter
      }
    , Cmd.batch [ getTodos api, Cmd.map FilterMsg filterCmd ]
    )


type Msg
    = GotTodos (Result Http.Error (List TodoItem))
    | ClickedAddTodo String
    | SaveTodoResponse (Result Http.Error ())
    | CompletedTodo TodoItem
    | CompletedTodoItemResponse TodoItem (Result Http.Error ())
    | ClickedCompleted TodoItem
    | FilterMsg Filter.Msg


update : Api.Api -> Msg -> Model -> ( Model, Cmd Msg )
update api msg model =
    case msg of
        GotTodos result ->
            case result of
                Ok todos ->
                    ( { model | todoList = RemoteData.Success todos }, Cmd.none )

                Err _ ->
                    ( { model | todoList = RemoteData.Failure "Unable to get TODOs" }, Cmd.none )

        FilterMsg filterMsg ->
            let
                ( updatedFilter, filterCmd ) =
                    Filter.update filterMsg model.filter
            in
            ( { model | filter = updatedFilter }
            , Cmd.map FilterMsg filterCmd
            )

        ClickedAddTodo newTodo ->
            ( model, postTodo api newTodo )

        SaveTodoResponse result ->
            case result of
                Ok _ ->
                    ( model, getTodos api )

                Err _ ->
                    ( { model | todoList = RemoteData.Failure "Unable to save TODOs" }, Cmd.none )

        ClickedCompleted todoItem ->
            let
                updatedTodoList =
                    model.todoList
                        |> RemoteData.map
                            (List.map
                                (\todo ->
                                    if todo.id == todoItem.id then
                                        { todo | completed = not todoItem.completed }

                                    else
                                        todo
                                )
                            )

                -- case model.todoList of
                --     RemoteData.Loading ->
                --         model.todoList
                --     RemoteData.Failure _ ->
                --         model.todoList
                --     RemoteData.Success todos ->
                --         todos
                --             |> List.map
                --                 (\todo ->
                --                     if todo.id == todoItem.id then
                --                         { todo | completed = not todoItem.completed }
                --                     else
                --                         todo
                --                 )
                --             |> RemoteData.Success
                --     RemoteData.NotAsked ->
                --         model.todoList
            in
            ( { model | todoList = updatedTodoList }
            , Cmd.none
            )

        CompletedTodo todoItem ->
            ( model, putTodo api todoItem )

        CompletedTodoItemResponse todoItem result ->
            let
                updatedTodoList =
                    model.todoList
                        |> RemoteData.map
                            (List.map
                                (\todo ->
                                    if todo.id == todoItem.id then
                                        { todo | completed = not todoItem.completed }

                                    else
                                        todo
                                )
                            )

                -- case model.todoList of
                --     RemoteData.Loading ->
                --         model.todoList
                --     RemoteData.Failure _ ->
                --         model.todoList
                --     RemoteData.Success todos ->
                --         todos
                --             |> List.map
                --                 (\todo ->
                --                     if todo.id == todoItem.id then
                --                         { todo | completed = not todoItem.completed }
                --                     else
                --                         todo
                --                 )
                --             |> RemoteData.Success
                --     RemoteData.NotAsked ->
                --         model.todoList
            in
            case result of
                Ok _ ->
                    ( { model | todoList = updatedTodoList }, Cmd.none )

                Err _ ->
                    ( { model | todoList = RemoteData.Failure "Unable to update todo" }, Cmd.none )


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg model =
    { title = "Todo List Page"
    , body =
        [ Header.view Route.TodoList
        , Html.map wrapMsg <|
            Html.div Styles.containerStyle
                [ Html.h1 [] [ Html.text "Todo list" ]
                , Filter.view FilterMsg ClickedAddTodo model.filter
                , todoListView model.todoList
                ]
        ]
    }


todoListView : RemoteData.RemoteData String (List TodoItem) -> Html.Html Msg
todoListView todoList =
    case todoList of
        RemoteData.Loading ->
            Html.div [] [ Html.text "Loading..." ]

        RemoteData.Failure error ->
            Html.div Styles.todoListErrorStyle [ Html.text error ]

        RemoteData.Success todos ->
            Html.ul Styles.todoListListStyle <| List.map todoView todos

        RemoteData.NotAsked ->
            Html.div [] [ Html.text "Not asked..." ]


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
