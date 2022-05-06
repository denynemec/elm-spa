module Api exposing (Api, addAuthorizationHeader, get, init, post, put)

import Http
import Json.Encode as Encode


type Api
    = Api (List Http.Header) String


init : String -> String -> Api
init jwtToken =
    Api (httpHeaders jwtToken)


httpHeaders : String -> List Http.Header
httpHeaders jwtToken =
    [ Http.header "Authorization" jwtToken
    ]


addAuthorizationHeader : String -> Api -> Api
addAuthorizationHeader jwtToken (Api headers baseApiUrl) =
    Api (headers ++ [ Http.header "Authorization" jwtToken ]) baseApiUrl


buildUrl : String -> Api -> String
buildUrl suffix (Api _ baseApiUrl) =
    baseApiUrl ++ suffix


put : (Result Http.Error () -> msg) -> Encode.Value -> String -> Api -> Cmd msg
put msg body endpointSuffix ((Api httpHeaders_ _) as api) =
    Http.request
        { method = "PUT"
        , headers = httpHeaders_
        , url = buildUrl endpointSuffix api
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        , timeout = Nothing
        , tracker = Nothing
        }


post : (Result Http.Error () -> msg) -> Encode.Value -> String -> Api -> Cmd msg
post msg body endpointSuffix api =
    Http.post
        { url = buildUrl endpointSuffix api
        , body = Http.jsonBody body
        , expect = Http.expectWhatever msg
        }


get msg decoder endpointSuffix api =
    Http.get
        { url = buildUrl endpointSuffix api
        , expect = Http.expectJson msg decoder
        }
