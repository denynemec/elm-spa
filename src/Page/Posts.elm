module Page.Posts exposing (Model, Msg, init, update, view)

import Browser
import Header
import Html exposing (Html)
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Loader
import Route
import Styles


type alias Model =
    Loader.Loader (List Post)


type Msg
    = FetchedPosts (Result Http.Error (List Post))
    | ClickedDeletePost PostId
    | DeletedResponse (List Post) PostId (Result Http.Error ())


type alias PostId =
    Int


type alias Post =
    { id : PostId
    , title : String
    }


init : String -> ( Model, Cmd Msg )
init api =
    ( Loader.loading
    , fetchPosts api
    )


fetchPosts : String -> Cmd Msg
fetchPosts api =
    Http.get
        { url = api ++ "posts"
        , expect = Http.expectJson FetchedPosts decodePosts
        }


decodePosts : Decode.Decoder (List Post)
decodePosts =
    Decode.list decodePost


decodePost : Decode.Decoder Post
decodePost =
    Decode.succeed Post
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "title" Decode.string


update : String -> Msg -> Model -> ( Model, Cmd Msg )
update api msg model =
    case msg of
        FetchedPosts postsResponse ->
            ( Loader.handleResponse postsResponse
            , Cmd.none
            )

        ClickedDeletePost postId ->
            -- TODO: remove this case - of (continue from last week)
            -- HINT: use msg payload
            case model of
                Loader.Loading ->
                    ( model
                    , Cmd.none
                    )

                Loader.Error _ ->
                    ( model
                    , Cmd.none
                    )

                Loader.Success posts ->
                    ( Loader.Loading
                    , deletePostCmd api posts postId
                    )

        DeletedResponse posts_ postId response ->
            let
                updatedPosts =
                    posts_
                        |> List.filter (.id >> (/=) postId)
            in
            ( response
                |> Result.map (always updatedPosts)
                |> Loader.handleResponse
            , Cmd.none
            )


deletePostCmd : String -> List Post -> PostId -> Cmd Msg
deletePostCmd api posts postId =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = api ++ "posts/" ++ String.fromInt postId
        , body = Http.emptyBody
        , expect = Http.expectWhatever (DeletedResponse posts postId)
        , timeout = Nothing
        , tracker = Nothing
        }


view : (Msg -> msg) -> Model -> Browser.Document msg
view wrapMsg model =
    let
        child =
            case model of
                Loader.Loading ->
                    [ Html.text "Loading posts ..." ]

                Loader.Error _ ->
                    [ Html.text "Posts error !!!" ]

                Loader.Success posts ->
                    postsView posts
    in
    { title = "Posts page"
    , body =
        [ Header.view Route.Posts
        , child
            |> Html.main_ Styles.mainStyleAttributes
            |> Html.map wrapMsg
        ]
    }


postsView : List Post -> List (Html Msg)
postsView =
    List.map postView


postView : Post -> Html Msg
postView { id, title } =
    Html.li Styles.listItemStyleAttributes
        [ Html.text title
        , Html.button
            [ Events.onClick <| ClickedDeletePost id ]
            [ Html.text "Remove post" ]
        ]
