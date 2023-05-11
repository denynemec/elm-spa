port module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Flags
import Html
import Page.NotFound as NotFound
import Page.TodoList as TodoList
import Page.TodoListSecond as TodoListSecond
import Route
import Url



-- TODO: 1) Add error log port for DecodeFlagsError model variant
-- TODO: 2) Add simple Home page
-- TODO: 3) Access Page.TodoList.Model data in this Main module (Debug.log)
-- TODO: 4) Implement Page.TodoList.Model as opaque type and compare with previous implementation
-- TODO: 5) Implement Api module as Opaque type
-- TODO: 6) Use Url.Builder


port logError : String -> Cmd msg


type Model
    = DecodeFlagsError String
    | AppInitialized Navigation.Key String Page


type Page
    = TodoList TodoList.Model
    | TodoListSecond TodoListSecond.Model
    | NotFound


init : Flags.RawFlags -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init rawFlags url key =
    case Flags.decodeFlags rawFlags of
        Err decodeFlagsError ->
            ( DecodeFlagsError decodeFlagsError
            , Cmd.batch [ logError decodeFlagsError ]
            )

        Ok flags ->
            let
                api =
                    Flags.toBaseApiUrl flags
            in
            url
                |> urlToPage api
                |> Tuple.mapFirst (AppInitialized key api)


urlToPage : String -> Url.Url -> ( Page, Cmd Msg )
urlToPage api =
    Route.fromUrl
        >> Maybe.map (routeToPage api)
        >> Maybe.withDefault ( NotFound, Cmd.none )


routeToPage : String -> Route.Route -> ( Page, Cmd Msg )
routeToPage api route =
    case route of
        Route.TodoList ->
            api
                |> TodoList.init
                |> Tuple.mapBoth TodoList (Cmd.map TodoListMsg)

        Route.TodoListSecond ->
            api
                |> TodoListSecond.init
                |> Tuple.mapBoth TodoListSecond (Cmd.map TodoListSecondMsg)


type Msg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | TodoListMsg TodoList.Msg
    | TodoListSecondMsg TodoListSecond.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, AppInitialized key _ _ ) ->
            ( model
            , case urlRequest of
                Browser.Internal url ->
                    url
                        |> Url.toString
                        |> Navigation.pushUrl key

                Browser.External href ->
                    Navigation.load href
            )

        ( ChangedUrl url, AppInitialized key api _ ) ->
            url
                |> urlToPage api
                |> Tuple.mapFirst (AppInitialized key api)

        -- ( ChangedUrl url, AppInitialized key api _ ) ->
        -- let
        --     ( page, pageCmd ) =
        --         urlToPage api url
        -- in
        -- ( AppInitialized key api page
        -- , pageCmd
        -- )
        ( TodoListMsg todoListMsg, AppInitialized key api (TodoList todoListModel) ) ->
            todoListModel
                |> TodoList.update api todoListMsg
                |> Tuple.mapBoth (TodoList >> AppInitialized key api) (Cmd.map TodoListMsg)

        ( TodoListSecondMsg todoListSecondMsg, AppInitialized key api (TodoListSecond todoListSecondModel) ) ->
            todoListSecondModel
                |> TodoListSecond.update api todoListSecondMsg
                |> Tuple.mapBoth (TodoListSecond >> AppInitialized key api) (Cmd.map TodoListSecondMsg)

        _ ->
            ( model
            , Cmd.none
            )


view : Model -> Browser.Document Msg
view model =
    case model of
        DecodeFlagsError _ ->
            { title = "Decode Flags Error"
            , body = [ Html.div [] [ Html.text "Something went wrong with flags decoding ..." ] ]
            }

        AppInitialized _ _ page ->
            pageView page


pageView : Page -> Browser.Document Msg
pageView page =
    case page of
        NotFound ->
            NotFound.view

        TodoList todoListModel ->
            TodoList.view TodoListMsg todoListModel

        TodoListSecond todoListSecondModel ->
            let
                _ =
                    Debug.log "TodoList" todoListSecondModel.newTodo
            in
            TodoListSecond.view TodoListSecondMsg todoListSecondModel


main : Program Flags.RawFlags Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }
