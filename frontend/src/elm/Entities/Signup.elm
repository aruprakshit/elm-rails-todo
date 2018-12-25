module Entities.Signup exposing (Model, initialModel)


type alias Model =
    { email : String
    , password : String
    , passwordConfirmation : String
    }


initialModel : Model
initialModel =
    Model "" "" ""
