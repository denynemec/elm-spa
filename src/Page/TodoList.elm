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
import Ui.Button as Button


type Model
    = ModelInternal ModelPayload


type alias ModelPayload =
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
getTodos api =
    Api.getExpectJson "todos" GotTodos decodeTodoList api


postTodo : Api.Api -> String -> Cmd Msg
postTodo api label =
    let
        body =
            Encode.object [ ( "label", Encode.string label ) ]
    in
    Api.post "todos" SaveTodoResponse body api


putTodo : Api.Api -> TodoItem -> Cmd Msg
putTodo api todoItem =
    let
        body =
            Encode.object
                [ ( "label", Encode.string todoItem.name )
                , ( "completed", Encode.bool <| not todoItem.completed )
                ]

        pathname =
            "todos/" ++ String.fromInt todoItem.id
    in
    Api.put pathname (CompletedTodoItemResponse todoItem) body api


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
    ( ModelInternal
        { todoList = Loading
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


update : Api.Api -> Msg -> Model -> ( Model, Cmd Msg )
update api msg ((ModelInternal ({ newTodo, todoList } as modelPayload)) as model) =
    case msg of
        GotTodos result ->
            case result of
                Ok todos ->
                    ( ModelInternal { modelPayload | todoList = Success todos }, Cmd.none )

                Err _ ->
                    ( ModelInternal { modelPayload | todoList = Error "Unable to get TODOs" }, Cmd.none )

        InsertedNewTodo todo ->
            ( ModelInternal { modelPayload | newTodo = todo }, Cmd.none )

        ClickedAddTodo ->
            ( model, postTodo api newTodo )

        SaveTodoResponse result ->
            case result of
                Ok _ ->
                    ( model, getTodos api )

                Err _ ->
                    ( ModelInternal { modelPayload | todoList = Error "Unable to save TODOs" }, Cmd.none )

        CompletedTodo todoItem ->
            -- let
            --     updatedTodoList =
            --         case model.todoList of
            --             Loading ->
            --                 model.todoList
            --             Error _ ->
            --                 model.todoList
            --             Success todos ->
            --                 todos
            --                     |> List.map
            --                         (\todo ->
            --                             if todo.id == todoItem.id then
            --                                 { todo | completed = not todoItem.completed }
            --                             else
            --                                 todo
            --                         )
            --                     |> Success
            -- in
            -- ( { model | todoList = updatedTodoList }, putTodo todoItem )
            ( model, putTodo api todoItem )

        CompletedTodoItemResponse todoItem result ->
            let
                updatedTodoList =
                    case todoList of
                        Loading ->
                            todoList

                        Error _ ->
                            todoList

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
                    ( ModelInternal { modelPayload | todoList = updatedTodoList }, Cmd.none )

                Err _ ->
                    ( ModelInternal { modelPayload | todoList = Error "Unable to update todo" }, Cmd.none )


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg (ModelInternal ({ todoList } as modelPayload)) =
    { title = "Todo List Page"
    , body =
        [ Header.view Route.TodoList
        , Html.map wrapMsg <|
            Html.div Styles.containerStyle
                [ Html.h1 [] [ Html.text "Todo list" ]
                , todoForm modelPayload
                , todoListView todoList
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
        [ Html.a (Styles.todoCheckStyle ++ [ Events.onClick <| CompletedTodo todoItem ]) [ Html.text checkText ]
        , Html.text todoItem.name
        ]


todoForm : ModelPayload -> Html.Html Msg
todoForm { newTodo } =
    Html.div Styles.formStyle
        [ Html.input (Styles.formInputStyle ++ [ Attributes.type_ "text", Attributes.value newTodo, Events.onInput InsertedNewTodo ]) []
        , Button.view
            { msg = ClickedAddTodo
            , label = "Add"
            }
        ]
