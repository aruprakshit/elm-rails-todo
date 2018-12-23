module Config exposing (AuthState(..), Model, backendDomain)

import Browser.Navigation as Nav


backendDomain : String
backendDomain =
    "http://localhost:5000"


type AuthState
    = NotAuthenticated
    | Authenticated String


type alias Model =
    { token : AuthState
    , key : Nav.Key
    }
