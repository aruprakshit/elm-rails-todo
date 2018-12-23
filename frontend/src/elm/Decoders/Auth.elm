module Decoders.Auth exposing (authDecoder)

import Entities.Signin exposing (AuthInfo)
import Json.Decode as JD


authDecoder : JD.Decoder AuthInfo
authDecoder =
    JD.map AuthInfo
        (JD.field "auth_token" JD.string)
