module Flags exposing (Flags, RawFlags, decodeFlags, toBaseApiUrl)

import Json.Decode as Decode
import Json.Encode as Encode


type alias RawFlags =
    Encode.Value


type Flags
    = Flags String


decodeFlags : RawFlags -> Result String Flags
decodeFlags =
    Decode.decodeValue decodeFlagsPayload
        >> Result.mapError Decode.errorToString


decodeFlagsPayload : Decode.Decoder Flags
decodeFlagsPayload =
    Decode.field "baseApiUrl" (Decode.map Flags Decode.string)


toBaseApiUrl : Flags -> String
toBaseApiUrl (Flags baseApiUrl) =
    baseApiUrl
