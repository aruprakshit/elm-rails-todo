module Entities.Signin exposing (Model, initialModel)


type alias Model =
    { email : String
    , password : String
    }


initialModel : Model
initialModel =
    Model "" ""
