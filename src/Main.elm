module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Flags
import Html
import Page.NotFound as NotFound
import Page.Posts as Posts
import Page.TodoList as TodoList
import Route
import Url



-- TODO: 0) Remove TODO from other modules
-- TODO: 1) Implement (ClickedCompleted TodoId) TodoList page
-- TODO: 2) Add error log port for DecodeFlagsError model variant
-- TODO: 3) Add simple Home page
-- TODO: 4) Access Page.Posts.Model and Page.TodoList.Model data in this Main module (Debug.log)
-- TODO: 6) Implement Page.Posts.Model as opaque type and compare with Page.TodoList.Model implementation
-- TODO: 6) Implement Api module as Opaque type
-- TODO: 7) Use Url.Builder


type Model
    = DecodeFlagsError String
    | AppInitialized Navigation.Key String Page


type Page
    = TodoList TodoList.Model
    | Posts Posts.Model
    | NotFound


init : Flags.RawFlags -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init rawFlags url key =
    case Flags.decodeFlags rawFlags of
        Err decodeFlagsError ->
            ( DecodeFlagsError decodeFlagsError
            , Cmd.none
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

        Route.Posts ->
            api
                |> Posts.init
                |> Tuple.mapBoth Posts (Cmd.map PostsMsg)


type Msg
    = ChangedUrl Url.Url
    | ClickedLink Browser.UrlRequest
    | PostsMsg Posts.Msg
    | TodoListMsg TodoList.Msg


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
        ( PostsMsg postsMsg, AppInitialized key api (Posts postsModel) ) ->
            postsModel
                |> Posts.update api postsMsg
                |> Tuple.mapBoth (Posts >> AppInitialized key api) (Cmd.map PostsMsg)

        ( TodoListMsg todoListMsg, AppInitialized key api (TodoList todoListModel) ) ->
            todoListModel
                |> TodoList.update api todoListMsg
                |> Tuple.mapBoth (TodoList >> AppInitialized key api) (Cmd.map TodoListMsg)

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

        Posts postsModel ->
            Posts.view PostsMsg postsModel


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
