module Api exposing (Api, getExpectJson, init, post, put, updateAuthorizationHeader)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type Api
    = ApiInternal InitParams


type alias InitParams =
    { baseApiUrl : String
    , token : String
    }


init : InitParams -> Api
init initParams =
    ApiInternal initParams


createAuthorizationHeader : String -> Http.Header
createAuthorizationHeader token =
    Http.header "authorization" <| "Bearer " ++ token


getExpectJson : String -> (Result Http.Error a -> msg) -> Decode.Decoder a -> Api -> Cmd msg
getExpectJson pathname msg decoder ((ApiInternal { baseApiUrl }) as api) =
    Http.request
        { method = "GET"
        , headers = createHeaders api
        , url = baseApiUrl ++ pathname
        , body = Http.emptyBody
        , expect = Http.expectJson msg decoder
        , timeout = Nothing
        , tracker = Nothing
        }


post : String -> (Result Http.Error () -> msg) -> Encode.Value -> Api -> Cmd msg
post pathname msg body ((ApiInternal { baseApiUrl }) as api) =
    Http.request
        { method = "POST"
        , headers = createHeaders api
        , url = baseApiUrl ++ pathname
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }


put : String -> (Result Http.Error () -> msg) -> Encode.Value -> Api -> Cmd msg
put pathname msg body ((ApiInternal { baseApiUrl }) as api) =
    Http.request
        { method = "PUT"
        , headers = createHeaders api
        , url = baseApiUrl ++ pathname
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }


createHeaders : Api -> List Http.Header
createHeaders (ApiInternal { token }) =
    [ createAuthorizationHeader token ]


updateAuthorizationHeader : String -> Api -> Api
updateAuthorizationHeader updatedToken (ApiInternal params) =
    ApiInternal { params | token = updatedToken }
