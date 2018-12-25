module Decoders.Auth exposing (AuthInfo, authDecoder)

import Json.Decode as JD


type alias AuthInfo =
    { authToken : String }


authDecoder : JD.Decoder AuthInfo
authDecoder =
    JD.map AuthInfo
        (JD.field "auth_token" JD.string)
