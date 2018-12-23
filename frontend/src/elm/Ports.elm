port module Ports exposing (clearAuthInfo, storeAuthInfo)

import Json.Encode as JE


port storeAuthInfo : JE.Value -> Cmd msg


port clearAuthInfo : JE.Value -> Cmd msg
