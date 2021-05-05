module Loader exposing (Loader(..), handleResponse, loading)

import Http


type Loader data
    = Loading
    | Error Http.Error
    | Success data


loading : Loader data
loading =
    Loading


handleResponse : Result Http.Error data -> Loader data
handleResponse responseResult =
    case responseResult of
        Ok data ->
            Success data

        Err httpError ->
            Error httpError
