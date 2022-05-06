port module Main exposing (main)

import Api
import Browser
import Browser.Navigation as Navigation
import Flags
import Html
import Page.Counter as Counter
import Page.Counter.Init as CounterInit
import Page.Counter.Model as CounterModel
import Page.Counter.Msg as CounterMsg
import Page.Counter.Update as CounterUpdate
import Page.Counter.View as CounterView
import Page.NotFound as NotFound
import Page.TodoList as TodoList
import Route
import Url


port errorLog : String -> Cmd msg



-- TODO: 1) Add error log port for DecodeFlagsError model variant
-- TODO: 2) Add simple Counter page
-- TODO: 3) Access Page.Counter.Model data in this Main module (Debug.log)
-- TODO: 4) Implement Page.Counter.Model as opaque type and compare with previous implementation
-- TODO: 5) Implement Api module as Opaque type
-- TODO: 6) Use Url.Builder


type Model
    = DecodeFlagsError String
    | AppInitialized Navigation.Key Api.Api Page


type Page
    = TodoList TodoList.Model
    | Counter Counter.Model
    | Counter2 CounterModel.Model
    | NotFound


init : Flags.RawFlags -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init rawFlags url key =
    case Flags.decodeFlags rawFlags of
        Err decodeFlagsError ->
            ( DecodeFlagsError decodeFlagsError
            , errorLog decodeFlagsError
            )

        Ok flags ->
            let
                api =
                    flags
                        |> Flags.toBaseApiUrl
                        |> Api.init "HARDCODED JWT TOKEN"
            in
            url
                |> urlToPage api
                |> Tuple.mapFirst (AppInitialized key api)


urlToPage : Api.Api -> Url.Url -> ( Page, Cmd Msg )
urlToPage api =
    Route.fromUrl
        >> Maybe.map (routeToPage api)
        >> Maybe.withDefault ( NotFound, Cmd.none )


routeToPage : Api.Api -> Route.Route -> ( Page, Cmd Msg )
routeToPage api route =
    case route of
        Route.TodoList ->
            api
                |> TodoList.init
                |> Tuple.mapBoth TodoList (Cmd.map TodoListMsg)

        Route.Counter ->
            Counter.init
                |> Tuple.mapBoth Counter (Cmd.map CounterMsg)

        Route.Counter2 ->
            CounterInit.init
                |> Tuple.mapBoth Counter2 (Cmd.map Counter2Msg)


type Msg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | TodoListMsg TodoList.Msg
    | CounterMsg Counter.Msg
    | Counter2Msg CounterMsg.Msg


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

        ( CounterMsg counterMsg, AppInitialized key api (Counter counterModel) ) ->
            counterModel
                |> Counter.update counterMsg
                |> Tuple.mapBoth (Counter >> AppInitialized key api) (Cmd.map CounterMsg)

        ( Counter2Msg counterMsg, AppInitialized key api (Counter2 counterModel) ) ->
            counterModel
                |> CounterUpdate.update counterMsg
                |> Tuple.mapBoth (Counter2 >> AppInitialized key api) (Cmd.map Counter2Msg)

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

        Counter counterModel ->
            Counter.view CounterMsg counterModel

        Counter2 counterModel ->
            CounterView.view Counter2Msg counterModel


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
