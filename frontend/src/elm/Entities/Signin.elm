module Entities.Signin exposing (AuthInfo, Model, initialModel)


type alias Model =
    { email : String
    , password : String
    }


type alias AuthInfo =
    { authToken : String }


initialModel : Model
initialModel =
    Model "" ""
