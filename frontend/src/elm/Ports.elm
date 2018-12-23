port module Ports exposing (storeAuthInfo)

import Json.Encode as JE


port storeAuthInfo : JE.Value -> Cmd msg
