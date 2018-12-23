module Entities.User exposing (Model, initialModel)


type alias Model =
    { email : String
    , username : String
    , id : Maybe Int
    }


initialModel : Model
initialModel =
    Model "" "" Nothing
