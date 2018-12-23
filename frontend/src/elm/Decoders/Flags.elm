module Decoders.Flags exposing (decodeFlags)

import Json.Decode as JD


decodeFlags : JD.Value -> Maybe String
decodeFlags json =
    case JD.decodeValue JD.string json of
        Ok value ->
            Just value

        Err _ ->
            Nothing
